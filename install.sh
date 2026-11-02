#!/usr/bin/env bash
# Pulseline one-step installer for macOS, Linux and Git Bash on Windows.
#   curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
# Detects Claude Code, GitHub Copilot CLI and OpenAI Codex CLI, installs the script
# once into ~/.pulseline, and wires it into each tool it finds. Every config file it
# edits is backed up first, and only the status line keys are touched.
set -euo pipefail

REPO_RAW=${PULSELINE_REPO_RAW:-https://raw.githubusercontent.com/leealvescosta/pulseline/main}
INSTALL_DIR=${PULSELINE_HOME:-$HOME/.pulseline}
CLAUDE_DIR=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
COPILOT_DIR=${COPILOT_HOME:-$HOME/.copilot}
CODEX_DIR=${CODEX_HOME:-$HOME/.codex}
CODEX_ITEMS='["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]'
STAMP=$(date +%Y%m%d%H%M%S)
HERE=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)

say()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
skip() { printf '\033[90m -  %s\033[0m\n' "$*"; }
die()  { printf '\033[31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# A tool counts as installed when its command is on PATH or its config folder exists.
has() { command -v "$1" >/dev/null 2>&1 || [ -d "$2" ]; }

has_claude=0;  has claude  "$CLAUDE_DIR"  && has_claude=1
has_copilot=0; has copilot "$COPILOT_DIR" && has_copilot=1
has_codex=0;   has codex   "$CODEX_DIR"   && has_codex=1

say "Looking for supported tools..."
if [ $has_claude = 1 ];  then say "  Claude Code: found"; else skip "  Claude Code: not found"; fi
if [ $has_copilot = 1 ]; then say "  Copilot CLI: found"; else skip "  Copilot CLI: not found"; fi
if [ $has_codex = 1 ];   then say "  Codex CLI: found";   else skip "  Codex CLI: not found"; fi
[ $((has_claude + has_copilot + has_codex)) -gt 0 ] \
  || die "None of Claude Code, GitHub Copilot CLI or OpenAI Codex CLI was found. Install one of them first, then run this again."

# Copy from a local clone when run from one, otherwise download.
fetch() {
  local name=$1 dest=$2
  if [ -f "$HERE/$name" ]; then cp "$HERE/$name" "$dest"
  elif command -v curl >/dev/null; then curl -fsSL "$REPO_RAW/$name" -o "$dest"
  elif command -v wget >/dev/null; then wget -qO "$dest" "$REPO_RAW/$name"
  else die "Need curl or wget to download $name."
  fi
}

# A real Python 3 (skips the Windows Store stub, which prints nothing).
PY=""
for p in python3 python; do
  if command -v "$p" >/dev/null && [ "$("$p" -c 'import sys; print(sys.version_info[0])' 2>/dev/null)" = "3" ]; then
    PY=$p; break
  fi
done

# Merge `statusLine` (and optionally a feature flag) into a JSON settings file, keeping every other key.
# Refuses to touch a file that isn't valid JSON.
merge_json() {
  local file=$1 cmd=$2 flag=${3:-}
  mkdir -p "$(dirname "$file")"
  [ -s "$file" ] || echo '{}' > "$file"
  cp "$file" "$file.bak-$STAMP"
  if [ -n "$PY" ]; then
    "$PY" - "$file" "$cmd" "$flag" 2>/dev/null <<'EOF' || return 1
import json, sys
path, cmd, flag = sys.argv[1:4]
with open(path, encoding="utf-8-sig") as f:
    data = json.load(f)
if not isinstance(data, dict):
    sys.exit(1)
data["statusLine"] = {"type": "command", "command": cmd}
if flag:
    enabled = data.setdefault("feature_flags", {}).setdefault("enabled", [])
    if flag not in enabled:
        enabled.append(flag)
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
EOF
  else
    jq --arg cmd "$cmd" --arg flag "$flag" '
      .statusLine = {type: "command", command: $cmd}
      | if $flag == "" then . else .feature_flags.enabled = ((.feature_flags.enabled // []) - [$flag] + [$flag]) end
    ' "$file" > "$file.tmp" 2>/dev/null || { rm -f "$file.tmp"; return 1; }
    mv "$file.tmp" "$file"
  fi
}

# --- install the script (Claude Code and Copilot CLI run it; Codex uses built-in items) ---
command_line=""
if [ $((has_claude + has_copilot)) -gt 0 ]; then
  mkdir -p "$INSTALL_DIR"
  if [ -n "$PY" ]; then
    script="$INSTALL_DIR/pulseline.py"; fetch pulseline.py "$script"
    command_line="$PY \"$script\""
  elif command -v jq >/dev/null; then
    script="$INSTALL_DIR/pulseline.sh"; fetch pulseline.sh "$script"
    command_line="bash \"$script\""
  else
    case "$(uname -s)" in
      Darwin) hint="brew install python   (or: brew install jq)";;
      Linux)  hint="sudo apt install python3   /   sudo dnf install python3   /   sudo pacman -S python";;
      *)      hint="winget install Python.Python.3.12";;
    esac
    die "Pulseline needs Python 3 (or jq). Install it, then run this again: $hint"
  fi
  chmod +x "$script"
  say "Installed $script"
fi

bad_json() { die "$1 is not valid JSON, so it was left unchanged. Fix it (see Troubleshooting in the README) and run this again."; }

if [ $has_claude = 1 ]; then
  merge_json "$CLAUDE_DIR/settings.json" "$command_line" || bad_json "$CLAUDE_DIR/settings.json"
  say "Claude Code: updated $CLAUDE_DIR/settings.json"
fi

if [ $has_copilot = 1 ]; then
  # Copilot CLI's custom status line sits behind the STATUS_LINE feature flag.
  merge_json "$COPILOT_DIR/settings.json" "$command_line" STATUS_LINE || bad_json "$COPILOT_DIR/settings.json"
  say "Copilot CLI: updated $COPILOT_DIR/settings.json"
fi

if [ $has_codex = 1 ]; then
  # Codex CLI has no custom-command status line, so enable its closest built-in items.
  cfg="$CODEX_DIR/config.toml"
  mkdir -p "$CODEX_DIR"; touch "$cfg"
  if grep -Eq '^[[:space:]]*status_line[[:space:]]*=' "$cfg"; then
    say "Codex CLI: $cfg already has a status_line; left it as is."
  else
    cp "$cfg" "$cfg.bak-$STAMP"
    if grep -Eq '^\[tui\][[:space:]]*$' "$cfg"; then
      awk -v line="status_line = $CODEX_ITEMS" '{ print } /^\[tui\][[:space:]]*$/ && !done { print line; done = 1 }' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    else
      printf '\n[tui]\nstatus_line = %s\n' "$CODEX_ITEMS" >> "$cfg"
    fi
    say "Codex CLI: updated $cfg"
  fi
fi

say "Done. Restart your tools to see Pulseline."
