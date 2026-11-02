# Pulseline one-step installer for Windows (PowerShell 5.1+).
#   irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
# Detects Claude Code, GitHub Copilot CLI and OpenAI Codex CLI, installs the script
# once into %USERPROFILE%\.pulseline, and wires it into each tool it finds. Every config
# file it edits is backed up first, and only the status line keys are touched.
$ErrorActionPreference = 'Stop'

$RepoRaw    = if ($env:PULSELINE_REPO_RAW) { $env:PULSELINE_REPO_RAW } else { 'https://raw.githubusercontent.com/leealvescosta/pulseline/main' }
$InstallDir = if ($env:PULSELINE_HOME) { $env:PULSELINE_HOME } else { Join-Path $env:USERPROFILE '.pulseline' }
$ClaudeDir  = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$CopilotDir = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE '.copilot' }
$CodexDir   = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$CodexItems = '["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$Stamp = Get-Date -Format 'yyyyMMddHHmmss'

function Say($m)  { Write-Host "==> $m" -ForegroundColor Cyan }
function Skip($m) { Write-Host " -  $m" -ForegroundColor DarkGray }
function Fail($m) { Write-Host "xx $m" -ForegroundColor Red; exit 1 }

# A tool counts as installed when its command is on PATH or its config folder exists.
function Test-Tool($cmd, $dir) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) -or (Test-Path $dir) }

$HasClaude  = Test-Tool 'claude' $ClaudeDir
$HasCopilot = Test-Tool 'copilot' $CopilotDir
$HasCodex   = Test-Tool 'codex' $CodexDir

Say 'Looking for supported tools...'
foreach ($t in @(@('Claude Code', $HasClaude), @('Copilot CLI', $HasCopilot), @('Codex CLI', $HasCodex))) {
    if ($t[1]) { Say "  $($t[0]): found" } else { Skip "  $($t[0]): not found" }
}
if (-not ($HasClaude -or $HasCopilot -or $HasCodex)) {
    Fail 'None of Claude Code, GitHub Copilot CLI or OpenAI Codex CLI was found. Install one of them first, then run this again.'
}

# A real Python 3; the Windows Store stub prints nothing, so it is skipped.
function Find-Python {
    # The leading commas keep one-item arrays from being flattened into strings.
    foreach ($c in @(@('py', '-3'), ,@('python'), ,@('python3'))) {
        if (-not (Get-Command $c[0] -ErrorAction SilentlyContinue)) { continue }
        try {
            $args_ = @($c | Select-Object -Skip 1) + @('-c', 'import sys; print(sys.executable * (sys.version_info[0] == 3))')  # no inner quotes: PS 5.1 mangles them
            $exe = (& $c[0] @args_ 2>$null | Select-Object -First 1)
            if ($exe) { return $exe.Trim() }
        } catch {}
    }
    return $null
}

# Merge `statusLine` (and optionally a feature flag) into a JSON settings file, keeping every other key.
# Python does the merge so formatting and non-ASCII text survive; values travel in env vars
# because PS 5.1 mangles quotes in native arguments. Returns $false if the file isn't valid JSON.
function Merge-Json($file, $command, $flag) {
    New-Item -ItemType Directory -Force (Split-Path $file) | Out-Null
    if ((Test-Path $file) -and (Get-Item $file).Length -gt 0) { Copy-Item $file "$file.bak-$Stamp" }
    $env:PL_FILE = $file; $env:PL_COMMAND = $command; $env:PL_FLAG = $flag
    @'
import json, os, sys
# PL_FLAG may be missing: Windows deletes a variable that is set to an empty string.
path, cmd, flag = os.environ["PL_FILE"], os.environ["PL_COMMAND"], os.environ.get("PL_FLAG", "")
data = {}
if os.path.exists(path) and os.path.getsize(path):
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
'@ | & { $ErrorActionPreference = 'Continue'; $input | & $Python - 2>$null }
    return ($LASTEXITCODE -eq 0)
}

function Bad-Json($file) { Fail "$file is not valid JSON, so it was left unchanged. Fix it (see Troubleshooting in the README) and run this again." }

# --- install the script (Claude Code and Copilot CLI run it; Codex uses built-in items) ---
if ($HasClaude -or $HasCopilot) {
    $Python = Find-Python
    if (-not $Python -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        $answer = Read-Host 'Pulseline needs Python 3. Install it now with winget? [Y/n]'
        if ($answer -notmatch '^[Nn]') {
            winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements
            $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
            $Python = Find-Python
        }
    }
    if (-not $Python) { Fail 'Python 3 not found. Install it from https://www.python.org/downloads/ (check "Add python.exe to PATH") and run this again.' }

    New-Item -ItemType Directory -Force $InstallDir | Out-Null
    $Script = Join-Path $InstallDir 'pulseline.py'
    $Local = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'pulseline.py' } else { $null }
    if ($Local -and (Test-Path $Local)) { Copy-Item $Local $Script -Force }
    else { Invoke-WebRequest -UseBasicParsing "$RepoRaw/pulseline.py" -OutFile $Script }
    Say "Installed $Script"

    # Full paths with forward slashes: they work in cmd and in Git Bash, and need no ~ expansion.
    $Command = '"{0}" "{1}"' -f ($Python -replace '\\', '/'), ($Script -replace '\\', '/')

    if ($HasClaude) {
        $f = Join-Path $ClaudeDir 'settings.json'
        if (-not (Merge-Json $f $Command '')) { Bad-Json $f }
        Say "Claude Code: updated $f"
    }
    if ($HasCopilot) {
        # Copilot CLI's custom status line sits behind the STATUS_LINE feature flag.
        $f = Join-Path $CopilotDir 'settings.json'
        if (-not (Merge-Json $f $Command 'STATUS_LINE')) { Bad-Json $f }
        Say "Copilot CLI: updated $f"
    }
}

if ($HasCodex) {
    # Codex CLI has no custom-command status line, so enable its closest built-in items.
    New-Item -ItemType Directory -Force $CodexDir | Out-Null
    $cfg = Join-Path $CodexDir 'config.toml'
    $text = if (Test-Path $cfg) { [IO.File]::ReadAllText($cfg) } else { '' }
    if ($text -match '(?m)^\s*status_line\s*=') {
        Say "Codex CLI: $cfg already has a status_line; left it as is."
    } else {
        if (Test-Path $cfg) { Copy-Item $cfg "$cfg.bak-$Stamp" }
        $line = "status_line = $CodexItems"
        if ($text -match '(?m)^\[tui\]\s*$') { $text = [regex]::new('(?m)^\[tui\]\s*$').Replace($text, "[tui]`n$line", 1) }
        else { $text = $text.TrimEnd() + "`n`n[tui]`n$line`n" }
        [IO.File]::WriteAllText($cfg, $text, $Utf8)
        Say "Codex CLI: updated $cfg"
    }
}

Say 'Done. Restart your tools to see Pulseline.'
