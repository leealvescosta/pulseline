# Pulseline

**English** · [Português](docs/README.pt-BR.md) · [Español](docs/README.es.md) · [日本語](docs/README.ja.md) · [简体中文](docs/README.zh-CN.md) · [한국어](docs/README.ko.md)

A colorful, width-aware status line for AI coding CLIs: model, folder, git branch, context window, usage limits, prompt-cache timer, session cost and lines changed.

| Tool | Support |
|---|---|
| [Claude Code](https://claude.com/claude-code) | Full: runs the Pulseline script |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Runs the Pulseline script (custom status line is an experimental Copilot feature) |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex can't run custom scripts, so the installer turns on its closest built-in items |

![Pulseline preview](assets/pulseline-preview.png)
<sub>From top: Claude Code in a wide terminal, in a narrow one, with <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code>, then GitHub Copilot CLI and OpenAI Codex CLI. <a href="assets/pulseline-preview.svg">Vector version (SVG)</a>.</sub>

## Features

| Segment | What it shows |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | Current model, working folder and git branch |
| 👾 `@agent` · `INSERT` | Active subagent and vim mode (Claude Code, only when present) |
| 🧠 context | Context window used, as a bar, a percentage and `used/total` tokens |
| 🕔 5h · 📅 7d | Claude subscription usage limits and the time until each one resets |
| 💾 cache | Time until the prompt cache goes cold, or `cold · 73k to rewrite` |
| 💰 cost | Session cost in USD and total session time |
| 🎫 premium | Premium requests used in the session (Copilot CLI) |
| 📝 +/- | Lines added and removed in this session |

- **Colors:** green below 70%, yellow from 70 to 89%, red from 90%.
- **Fits any width:** segments wrap onto a new line as the window narrows. If they still don't fit in two lines, the bars and then the reset times are hidden.
- **Only what's available:** a segment the tool doesn't report (for example rate limits on an API key) is simply left out.
- **Two equivalent versions:** `pulseline.py` (Python 3, no packages) and `pulseline.sh` (bash + jq). They print the same thing.

## Quick install (one click)

The installer:

1. **Detects** which of Claude Code, Copilot CLI and Codex CLI you have, and tells you what it found.
2. Installs the script once into `~/.pulseline/` (Windows: `C:\Users\<you>\.pulseline\`).
3. Adds **only** the status line keys to each tool's settings, keeping everything else. A backup (`settings.json.bak-<date>`) is saved before any change, and a file that isn't valid JSON is left untouched.

Running it again is safe: it updates the same keys instead of adding duplicates.

### Windows

**Easiest:** download the repository ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)), unzip it and double-click **`install-windows.cmd`**.

Or paste this into PowerShell:

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

If Python 3 is missing, the installer offers to install it with `winget`.

### macOS

**Easiest:** download the ZIP, unzip it and double-click **`install-macos.command`**. The first time, macOS may block it: right-click the file → **Open** → **Open**.

Or paste this into Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

Then **restart your tool** (Claude Code, Copilot CLI or Codex). The status line appears at the bottom of the terminal.

## Manual install

### Before you edit: the rules that prevent most errors

Every config file here is JSON. These are the mistakes that break it (or that make the tool silently ignore your status line):

1. **Merge, don't replace.** Your `settings.json` probably has other settings already. Add the `statusLine` block next to them; don't paste over the whole file.
2. **`statusLine` goes at the top level**, a direct child of the outermost `{ }`. It must **not** go inside another block such as `env`, `permissions` or `extraKnownMarketplaces`.
3. **Commas go between items, never after the last one.**
4. **Check the file before restarting** (see [Validate your settings.json](#validate-your-settingsjson)).

**Wrong** — `statusLine` ended up inside `extraKnownMarketplaces`:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ inside another block
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

Claude Code then reads `statusLine` as a plugin marketplace, ignores it and warns:

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

**Right** — close the other block first, then add `statusLine` as its sibling:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← closes extraKnownMarketplaces, then a comma
  "statusLine": {                         // ✓ top level
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

(The `//` comments are only there to explain; JSON doesn't allow them, so don't copy them.)

### Step 1: copy the script

Create the folder `~/.pulseline/` (Windows: `C:\Users\<you>\.pulseline\`) and copy `pulseline.py` into it. Use `pulseline.sh` instead if you don't have Python 3 but have `bash` and `jq`.

### Step 2: pick your command

| System | `command` value |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

On Windows:

- Use **forward slashes** (`C:/Users/...`). Backslashes in JSON must be doubled (`C:\\Users\\...`), and forgetting that is a common error.
- Use the **full path** instead of `~`, which isn't expanded everywhere.
- If your path has spaces, quote it inside the string: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### Step 3a: Claude Code

File: `~/.claude/settings.json` (Windows: `C:\Users\<you>\.claude\settings.json`). Create it with `{}` if it doesn't exist. Add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### Step 3b: GitHub Copilot CLI

File: `~/.copilot/settings.json` (or the folder in `COPILOT_HOME`). Copilot's custom status line is experimental, so it also needs the `STATUS_LINE` feature flag:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  },
  "feature_flags": {
    "enabled": ["STATUS_LINE"]
  }
}
```

If `feature_flags.enabled` already exists, add `"STATUS_LINE"` to that list instead of creating a second one. You can also start Copilot with `copilot --experimental` or run `/experimental` inside it. Restart Copilot afterwards (`/restart`): flags are read at startup.

### Step 3c: OpenAI Codex CLI

Codex doesn't run custom scripts. Add its built-in items to `~/.codex/config.toml` (TOML, not JSON):

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

If the file already has a `[tui]` section, put the `status_line` line under it; don't create a second `[tui]`. You can also choose items interactively with `/statusline` inside Codex.

### Step 4: restart and check

Restart the tool. If the status line doesn't appear, see [Troubleshooting](#troubleshooting).

### Validate your settings.json

Run this before restarting. It prints the file back if it's valid, or the line and column of the error:

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

Then check that `statusLine` is at the top level. This must print your command; if it prints `null`, the block is nested somewhere else:

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## Options

Set these as environment variables. For Claude Code, the easiest place is the `env` block of `~/.claude/settings.json` (a top-level block, like `statusLine`):

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

For Copilot CLI, set them in your shell profile (`export PULSELINE_HIDE=cost` in `~/.zshrc` / `~/.bashrc`, or `setx PULSELINE_HIDE cost` on Windows).

| Variable | Effect |
|---|---|
| `PULSELINE_HIDE` | Comma-separated segments to hide: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | Text labels instead of emojis (`ctx`, `5h`, `cost`…), for terminals or fonts that can't draw emojis |
| `PULSELINE_HOME` | Installer: where to put the script (default `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | Installer: your tool's config folder, if it isn't in the default place |

## About the cache indicator

`💾 cache 47m of 1h` is the time left before the conversation's prompt cache expires, and the TTL in use. It turns yellow when less than 20% of the TTL remains and shows `cold` in red after it expires, with how many tokens the next message will write to the cache again.

Claude Code picks the TTL per request: **1 hour** on a Claude subscription within plan usage, **5 minutes** on extra usage, an API key or a cloud provider, or when `FORCE_PROMPT_CACHING_5M=1` / `promptCacheTtl: "5m"` is set. Writing to the 5-minute cache costs 1.25× the input price and to the 1-hour cache 2×; cache reads cost 0.1× or less. See [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime).

The script reads Claude Code's own `prompt_cache` data (v2.1.251+); on older versions it estimates from the session transcript. This segment is Claude Code only.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Warning `Invalid marketplace entry was ignored ... statusLine` | `statusLine` is nested inside `extraKnownMarketplaces`. Move it to the top level ([see above](#before-you-edit-the-rules-that-prevent-most-errors)). |
| The tool says settings.json is invalid, or ignores all your settings | A comma or brace is wrong. [Validate the file](#validate-your-settingsjson); the error shows the line. |
| Status line doesn't appear, no error | Run the script by hand: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. It should print two lines. If it does, `statusLine` is probably nested: check it's at the top level. |
| Copilot CLI shows nothing | Check the `STATUS_LINE` feature flag (or start with `--experimental`) and restart Copilot. |
| `jq: command not found` | Install `jq`, or switch to the Python version. |
| Windows: `python` opens the Microsoft Store | Install Python from [python.org](https://www.python.org/downloads/) (check *Add python.exe to PATH*) and run the installer again. |
| Squares instead of emojis | Set `PULSELINE_NO_EMOJI=1`, or use a font with emoji support. |
| You broke settings.json and want it back | Each installer run saves `settings.json.bak-<date>` next to it. |

## Uninstall

1. Remove the `statusLine` block from `~/.claude/settings.json` and/or `~/.copilot/settings.json` (and `STATUS_LINE` from Copilot's `feature_flags.enabled` if you don't use it for anything else).
2. For Codex, remove the `status_line` line from `~/.codex/config.toml`.
3. Delete the `~/.pulseline/` folder and restart your tools.

## License

[MIT](LICENSE)
