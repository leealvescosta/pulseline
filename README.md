# Pulseline

**English** · [Português](docs/README.pt-BR.md) · [Español](docs/README.es.md) · [日本語](docs/README.ja.md) · [简体中文](docs/README.zh-CN.md) · [한국어](docs/README.ko.md)

Pulseline is a colorful status line for AI coding tools in the terminal. It shows your model, folder and git branch, how full the context window is, how much of your usage limits you've spent, when the prompt cache goes cold, what the session has cost and how many lines you've changed. It adapts to the width of your terminal.

| Tool | Support |
|---|---|
| [Claude Code](https://claude.com/claude-code) | Full support. It runs the Pulseline script. |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Runs the Pulseline script. Custom status lines are still an experimental Copilot feature. |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex can't run custom scripts, so the installer turns on its closest built-in items instead. |

![Pulseline preview](assets/pulseline-preview.png)
<sub>From top: Claude Code in a wide terminal, in a narrow one, with <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code>, then GitHub Copilot CLI and OpenAI Codex CLI. <a href="assets/pulseline-preview.svg">Vector version (SVG)</a>.</sub>

## What it shows

| Segment | What it shows |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | The current model, working folder and git branch |
| 👾 `@agent` · `INSERT` | The active subagent and vim mode (Claude Code, when they're in use) |
| 🧠 context | How much of the context window is used, as a bar, a percentage and `used/total` tokens |
| 🕔 5h · 📅 7d | Your Claude subscription limits and how long until each one resets |
| 💾 cache | How long until the prompt cache goes cold, or `cold · 73k to rewrite` once it has |
| 💰 cost | What the session has cost in USD, and how long it has been running |
| 🎫 premium | Premium requests used in the session (Copilot CLI) |
| 📝 +/- | Lines added and removed in this session |

Numbers are green below 70%, yellow from 70 to 89% and red from 90%.

When the window gets narrower, segments move to a new line. If two lines still aren't enough, Pulseline hides the bars first and then the reset times.

If a tool doesn't report something (rate limits when you use an API key, for example), that segment just doesn't appear.

There are two versions that print exactly the same thing: `pulseline.py` needs Python 3 and nothing else, and `pulseline.sh` needs bash and jq.

## Quick install

The installer looks for Claude Code, Copilot CLI and Codex CLI and tells you which ones it found. It puts the script in `~/.pulseline/` (on Windows, `C:\Users\<you>\.pulseline\`) and then adds the status line settings to each tool, leaving the rest of your settings alone.

Before it changes a file, it saves a copy next to it (`settings.json.bak-<date>`). If a file isn't valid JSON, it doesn't touch it. You can run it again whenever you like; it updates the same settings instead of adding them twice.

### Windows

The easiest way: download the project ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)), unzip it and double-click `install-windows.cmd`.

You can also paste this into PowerShell:

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

If you don't have Python 3, the installer offers to install it for you with `winget`.

### macOS

The easiest way: download the ZIP, unzip it and double-click `install-macos.command`. macOS may block it the first time. If it does, right-click the file, choose **Open**, then **Open** again.

You can also paste this into Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

When it's done, restart Claude Code, Copilot CLI or Codex. The status line shows up at the bottom of the terminal.

## Manual install

### Read this before you edit

All of these settings files are JSON, and a small mistake can break the whole file or make the tool quietly ignore your status line. Four things to keep in mind:

1. Your `settings.json` probably already has other settings. Add the `statusLine` block next to them instead of pasting over the file.
2. `statusLine` has to sit at the top level, directly inside the outermost `{ }`. If it ends up inside another block such as `env`, `permissions` or `extraKnownMarketplaces`, it won't work.
3. Put a comma between items, but not after the last one.
4. Check the file before you restart (see [Check your settings.json](#check-your-settingsjson)).

Here is a common mistake. The `statusLine` block ended up inside `extraKnownMarketplaces`:

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

Claude Code then thinks `statusLine` is a plugin marketplace, ignores it and shows this warning:

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

To fix it, close the other block first and add `statusLine` after it, at the same level:

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

The `//` comments are only there to explain. JSON doesn't allow comments, so leave them out of your file.

### Step 1: copy the script

Create the folder `~/.pulseline/` (on Windows, `C:\Users\<you>\.pulseline\`) and copy `pulseline.py` into it. If you don't have Python 3 but do have `bash` and `jq`, use `pulseline.sh` instead.

### Step 2: pick your command

| System | `command` value |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

A few tips for Windows:

- Use forward slashes (`C:/Users/...`). Backslashes have to be doubled in JSON (`C:\\Users\\...`), and it's easy to forget.
- Write the full path instead of `~`, because `~` isn't expanded everywhere.
- If the path has spaces, put quotes around it inside the string: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### Step 3a: Claude Code

Open `~/.claude/settings.json` (on Windows, `C:\Users\<you>\.claude\settings.json`). If it doesn't exist, create it with `{}` inside. Then add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### Step 3b: GitHub Copilot CLI

Open `~/.copilot/settings.json` (or the folder set in `COPILOT_HOME`). Copilot's custom status line is still experimental, so you also need to turn on the `STATUS_LINE` feature flag:

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

If you already have a `feature_flags.enabled` list, add `"STATUS_LINE"` to it rather than creating a second one. Starting Copilot with `copilot --experimental`, or running `/experimental` inside it, also works. Copilot reads flags when it starts, so restart it afterwards (`/restart`).

### Step 3c: OpenAI Codex CLI

Codex doesn't run custom scripts, but you can turn on its built-in items in `~/.codex/config.toml`. This file is TOML, not JSON:

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

If the file already has a `[tui]` section, put the `status_line` line under it instead of adding a second `[tui]`. You can also pick the items from a menu with `/statusline` inside Codex.

### Step 4: restart and check

Restart the tool. If the status line doesn't appear, have a look at [Troubleshooting](#troubleshooting).

### Check your settings.json

Run this before restarting. If the file is valid, it prints it back. If not, it tells you the line and column of the problem:

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

Then make sure `statusLine` is at the top level. This should print your command. If it prints `null`, the block is nested inside something else:

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## Options

Pulseline reads a few environment variables. For Claude Code, the easiest place to set them is the `env` block in `~/.claude/settings.json`, which also goes at the top level, like `statusLine`:

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

For Copilot CLI, set them in your shell profile: `export PULSELINE_HIDE=cost` in `~/.zshrc` or `~/.bashrc`, or `setx PULSELINE_HIDE cost` on Windows.

| Variable | What it does |
|---|---|
| `PULSELINE_HIDE` | Hides the segments you list, separated by commas: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | Shows text labels (`ctx`, `5h`, `cost`…) instead of emojis, for terminals or fonts that can't display them |
| `PULSELINE_HOME` | Tells the installer where to put the script (default `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | Tells the installer where your tool keeps its settings, if you moved them |

## How the cache timer works

`💾 cache 47m of 1h` means the conversation's prompt cache expires in 47 minutes, out of a 1-hour lifetime. The number turns yellow when less than 20% of that time is left. Once the cache expires you'll see `cold` in red, along with how many tokens your next message will have to write to the cache again.

Claude Code picks the cache lifetime for each request. You get 1 hour on a Claude subscription while you're within your plan's usage. You get 5 minutes on extra usage, with an API key or a cloud provider, or when you set `FORCE_PROMPT_CACHING_5M=1` or `promptCacheTtl: "5m"`. Writing to the 5-minute cache costs 1.25× the input price and writing to the 1-hour cache costs 2×; reading from the cache costs 0.1× or less. [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime) has the details.

Pulseline uses the `prompt_cache` data that Claude Code sends (version 2.1.251 and later). On older versions it estimates the timer from the session transcript. This segment only appears in Claude Code.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Warning `Invalid marketplace entry was ignored ... statusLine` | `statusLine` is inside `extraKnownMarketplaces`. Move it to the top level ([see the example above](#read-this-before-you-edit)). |
| The tool says settings.json is invalid, or ignores all your settings | A comma or brace is off. [Check the file](#check-your-settingsjson) and it will show you the line. |
| The status line doesn't appear and there's no error | Run the script yourself: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. You should see two lines. If you do, `statusLine` is probably nested inside another block, so check that it's at the top level. |
| Copilot CLI shows nothing | Make sure the `STATUS_LINE` feature flag is on (or start Copilot with `--experimental`), then restart it. |
| `jq: command not found` | Install `jq`, or use the Python version. |
| On Windows, `python` opens the Microsoft Store | Install Python from [python.org](https://www.python.org/downloads/), tick *Add python.exe to PATH*, and run the installer again. |
| You see squares instead of emojis | Set `PULSELINE_NO_EMOJI=1`, or switch to a font that supports emojis. |
| You broke settings.json and want the old one back | Every time the installer runs, it saves a `settings.json.bak-<date>` copy next to the file. |

## Uninstall

1. Remove the `statusLine` block from `~/.claude/settings.json` and/or `~/.copilot/settings.json`. In Copilot, you can also remove `STATUS_LINE` from `feature_flags.enabled` if nothing else needs it.
2. For Codex, delete the `status_line` line from `~/.codex/config.toml`.
3. Delete the `~/.pulseline/` folder and restart your tools.

## License

[MIT](LICENSE)
