# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · [Español](README.es.md) · [日本語](README.ja.md) · **简体中文** · [한국어](README.ko.md)

一款为 AI 编程 CLI 打造的彩色状态栏，能根据终端宽度自动调整：显示模型、文件夹、git 分支、上下文窗口、用量限制、提示缓存计时、会话费用和改动行数。

| 工具 | 支持情况 |
|---|---|
| [Claude Code](https://claude.com/claude-code) | 完整支持：运行 Pulseline 脚本 |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | 运行 Pulseline 脚本（自定义状态栏是 Copilot 的实验性功能） |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex 无法运行自定义脚本，因此安装程序会启用与之最接近的内置项 |

![Pulseline 预览](../assets/pulseline-preview.png)
<sub>从上到下：宽终端中的 Claude Code、窄终端中的 Claude Code、启用 <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code> 时的效果，以及 GitHub Copilot CLI 和 OpenAI Codex CLI。<a href="../assets/pulseline-preview.svg">矢量版 (SVG)</a></sub>

## 功能

| 段 | 显示内容 |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | 当前模型、工作文件夹和 git 分支 |
| 👾 `@agent` · `INSERT` | 当前子代理和 vim 模式（仅 Claude Code，且仅在存在时显示） |
| 🧠 context | 上下文窗口用量，以进度条、百分比和 `used/total` token 数显示 |
| 🕔 5h · 📅 7d | Claude 订阅的用量限制，以及各自距离重置的时间 |
| 💾 cache | 距离提示缓存失效的时间，或 `cold · 73k to rewrite` |
| 💰 cost | 会话费用（美元）和会话总时长 |
| 🎫 premium | 本次会话使用的高级请求数（Copilot CLI） |
| 📝 +/- | 本次会话新增和删除的行数 |

- **颜色：** 低于 70% 为绿色，70% 到 89% 为黄色，90% 及以上为红色。
- **适应任意宽度：** 窗口变窄时，各段会换到新的一行。如果两行仍然放不下，会先隐藏进度条，再隐藏重置时间。
- **只显示可用的信息：** 工具没有提供的段（例如使用 API 密钥时的用量限制）会直接省略。
- **两个等效版本：** `pulseline.py`（Python 3，无需安装任何包）和 `pulseline.sh`（bash + jq），两者输出完全相同。

## 快速安装（一键）

安装程序会：

1. **检测**你安装了 Claude Code、Copilot CLI 和 Codex CLI 中的哪些，并告诉你检测结果。
2. 将脚本一次性安装到 `~/.pulseline/`（Windows：`C:\Users\<you>\.pulseline\`）。
3. **只**在每个工具的设置中添加状态栏相关的键，其余内容保持不变。每次修改前都会先保存备份（`settings.json.bak-<date>`），如果文件不是有效的 JSON，则不会改动它。

重复运行是安全的：它会更新相同的键，而不会添加重复项。

### Windows

**最简单的方法：** 下载仓库（[Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)），解压后双击 **`install-windows.cmd`**。

或者在 PowerShell 中粘贴：

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

如果没有安装 Python 3，安装程序会提示用 `winget` 安装。

### macOS

**最简单的方法：** 下载 ZIP，解压后双击 **`install-macos.command`**。首次运行时 macOS 可能会阻止它：右键点击该文件 → **Open** → **Open**（打开）。

或者在终端中粘贴：

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

然后**重启你的工具**（Claude Code、Copilot CLI 或 Codex）。状态栏会出现在终端底部。

## 手动安装

### 编辑之前: 避免大多数错误的规则

这里涉及的配置文件都是 JSON。下面这些错误会把文件弄坏（或者让工具悄悄忽略你的状态栏）：

1. **合并，而不是替换。** 你的 `settings.json` 里很可能已经有其他设置。把 `statusLine` 块加在它们旁边，不要覆盖整个文件。
2. **`statusLine` 必须放在顶层**，作为最外层 `{ }` 的直接子项。它**不能**放在 `env`、`permissions` 或 `extraKnownMarketplaces` 等其他块里面。
3. **逗号放在各项之间，最后一项后面不加逗号。**
4. **重启前先检查文件**（参见[验证你的 settings.json](#验证你的-settingsjson)）。

**错误** — `statusLine` 被放进了 `extraKnownMarketplaces` 里面：

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ 在另一个块里面
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

这时 Claude Code 会把 `statusLine` 当作一个插件市场来读取，忽略它并发出警告：

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

**正确** — 先关闭另一个块，再把 `statusLine` 作为它的同级项添加：

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← 关闭 extraKnownMarketplaces，然后加逗号
  "statusLine": {                         // ✓ 顶层
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

（`//` 注释只是用来说明的；JSON 不允许注释，所以不要复制它们。）

### 第 1 步：复制脚本

创建文件夹 `~/.pulseline/`（Windows：`C:\Users\<you>\.pulseline\`），把 `pulseline.py` 复制进去。如果你没有 Python 3，但有 `bash` 和 `jq`，就改用 `pulseline.sh`。

### 第 2 步：选择你的命令

| 系统 | `command` 的值 |
|---|---|
| macOS / Linux，Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux，bash | `bash ~/.pulseline/pulseline.sh` |
| Windows，Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

在 Windows 上：

- 使用**正斜杠**（`C:/Users/...`）。JSON 中的反斜杠必须写成两个（`C:\\Users\\...`），忘记这一点是常见错误。
- 使用**完整路径**而不是 `~`，因为 `~` 并非在所有地方都会被展开。
- 如果路径中有空格，要在字符串内用引号括起来：`"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`。

### 第 3a 步：Claude Code

文件：`~/.claude/settings.json`（Windows：`C:\Users\<you>\.claude\settings.json`）。如果文件不存在，就创建一个内容为 `{}` 的文件。添加：

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### 第 3b 步：GitHub Copilot CLI

文件：`~/.copilot/settings.json`（或 `COPILOT_HOME` 指定的文件夹）。Copilot 的自定义状态栏是实验性功能，因此还需要开启 `STATUS_LINE` 功能标志：

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

如果 `feature_flags.enabled` 已经存在，就把 `"STATUS_LINE"` 加到这个列表里，不要再新建一个。你也可以用 `copilot --experimental` 启动 Copilot，或在 Copilot 中运行 `/experimental`。之后重启 Copilot（`/restart`）：功能标志是在启动时读取的。

### 第 3c 步：OpenAI Codex CLI

Codex 不运行自定义脚本。把它的内置项添加到 `~/.codex/config.toml`（TOML，不是 JSON）：

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

如果文件中已经有 `[tui]` 段，就把 `status_line` 这一行放在它下面，不要再创建第二个 `[tui]`。你也可以在 Codex 中用 `/statusline` 交互式地选择要显示的项。

### 第 4 步：重启并检查

重启工具。如果状态栏没有出现，请参阅[故障排查](#故障排查)。

### 验证你的 settings.json

重启前运行下面的命令。如果文件有效，它会把文件内容打印出来；否则会显示错误所在的行和列：

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

然后确认 `statusLine` 位于顶层。下面的命令应该打印出你的命令；如果打印的是 `null`，说明这个块被嵌套在了别的地方：

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## 选项

以下选项通过环境变量设置。对于 Claude Code，最方便的位置是 `~/.claude/settings.json` 中的 `env` 块（和 `statusLine` 一样是顶层块）：

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

对于 Copilot CLI，请在 shell 配置文件中设置（在 `~/.zshrc` / `~/.bashrc` 中写 `export PULSELINE_HIDE=cost`，Windows 上用 `setx PULSELINE_HIDE cost`）。

| 变量 | 作用 |
|---|---|
| `PULSELINE_HIDE` | 要隐藏的段，用逗号分隔：`branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | 用文字标签代替表情符号（`ctx`、`5h`、`cost`…），适用于无法显示表情符号的终端或字体 |
| `PULSELINE_HOME` | 安装程序：脚本的存放位置（默认 `~/.pulseline`） |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | 安装程序：工具的配置文件夹（如果不在默认位置） |

## 关于缓存指示器

`💾 cache 47m of 1h` 表示对话的提示缓存距离过期还剩多少时间，以及当前使用的 TTL。剩余时间不足 TTL 的 20% 时会变成黄色；过期后会以红色显示 `cold`，并给出下一条消息需要重新写入缓存的 token 数。

Claude Code 会为每个请求选择 TTL：在套餐用量范围内使用 Claude 订阅时为 **1 小时**；使用额外用量、API 密钥或云服务商，或者设置了 `FORCE_PROMPT_CACHING_5M=1` / `promptCacheTtl: "5m"` 时为 **5 分钟**。写入 5 分钟缓存的费用是输入价格的 1.25 倍，写入 1 小时缓存是 2 倍；读取缓存的费用为 0.1 倍或更低。参见 [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime)。

脚本读取 Claude Code 自身的 `prompt_cache` 数据（v2.1.251+）；在更早的版本中，则根据会话记录进行估算。此段仅适用于 Claude Code。

## 故障排查

| 症状 | 解决方法 |
|---|---|
| 出现警告 `Invalid marketplace entry was ignored ... statusLine` | `statusLine` 嵌套在了 `extraKnownMarketplaces` 里面。把它移到顶层（[见上文](#编辑之前-避免大多数错误的规则)）。 |
| 工具提示 settings.json 无效，或忽略了你的所有设置 | 某个逗号或花括号写错了。[验证文件](#验证你的-settingsjson)，错误信息会显示所在行。 |
| 状态栏没有出现，也没有报错 | 手动运行脚本：`echo '{}' \| python3 ~/.pulseline/pulseline.py`。它应该输出两行。如果能输出，那么 `statusLine` 很可能被嵌套了：检查它是否位于顶层。 |
| Copilot CLI 什么都不显示 | 检查 `STATUS_LINE` 功能标志（或用 `--experimental` 启动），然后重启 Copilot。 |
| `jq: command not found` | 安装 `jq`，或改用 Python 版本。 |
| Windows：运行 `python` 会打开 Microsoft Store | 从 [python.org](https://www.python.org/downloads/) 安装 Python（勾选 *Add python.exe to PATH*），然后重新运行安装程序。 |
| 表情符号显示为方块 | 设置 `PULSELINE_NO_EMOJI=1`，或使用支持表情符号的字体。 |
| 你把 settings.json 弄坏了，想恢复 | 安装程序每次运行都会在同一位置保存一个 `settings.json.bak-<date>`。 |

## 卸载

1. 从 `~/.claude/settings.json` 和/或 `~/.copilot/settings.json` 中删除 `statusLine` 块（如果 Copilot 的 `feature_flags.enabled` 中的 `STATUS_LINE` 没有其他用途，也一并删除）。
2. 对于 Codex，从 `~/.codex/config.toml` 中删除 `status_line` 这一行。
3. 删除 `~/.pulseline/` 文件夹，然后重启你的工具。

## 许可证

[MIT](../LICENSE)
