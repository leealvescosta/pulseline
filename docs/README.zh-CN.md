# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · [Español](README.es.md) · [日本語](README.ja.md) · **简体中文** · [한국어](README.ko.md)

Pulseline 是一个给终端里的 AI 编程工具用的彩色状态栏。它会显示模型、文件夹和 git 分支，上下文窗口用了多少，用量限制已经花掉多少，提示缓存什么时候失效，这次会话花了多少钱，以及你改了多少行。它会根据终端宽度自动调整。

| 工具 | 支持情况 |
|---|---|
| [Claude Code](https://claude.com/claude-code) | 完整支持。运行 Pulseline 脚本。 |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | 运行 Pulseline 脚本。自定义状态栏目前还是 Copilot 的实验性功能。 |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex 不能运行自定义脚本，所以安装程序会改为启用它最接近的内置项。 |

![Pulseline 预览](../assets/pulseline-preview.png)
<sub>从上到下：宽终端中的 Claude Code、窄终端中的 Claude Code、启用 <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code> 时的效果，以及 GitHub Copilot CLI 和 OpenAI Codex CLI。<a href="../assets/pulseline-preview.svg">矢量版 (SVG)</a></sub>

## 显示内容

| 段 | 显示什么 |
|---|---|
| 🤖 模型 · 📁 文件夹 · 🌿 分支 | 当前模型、工作文件夹和 git 分支 |
| 👾 `@agent` · `INSERT` | 当前的子代理和 vim 模式（Claude Code 中正在使用时） |
| 🧠 上下文 | 上下文窗口用了多少，用进度条、百分比和 `used/total` token 数显示 |
| 🕔 5h · 📅 7d | 你的 Claude 订阅限额，以及每个限额还有多久重置 |
| 💾 缓存 | 提示缓存还有多久失效，失效后显示 `cold · 73k to rewrite` |
| 💰 费用 | 这次会话花了多少美元，以及已经运行了多久 |
| 🎫 premium | 本次会话用掉的高级请求数（Copilot CLI） |
| 📝 +/- | 本次会话新增和删除的行数 |

数字在 70% 以下是绿色，70% 到 89% 是黄色，90% 及以上是红色。

窗口变窄时，各段会换到新的一行。如果两行还放不下，Pulseline 会先隐藏进度条，再隐藏重置时间。

如果某个工具不提供某项数据（比如用 API 密钥时的速率限制），对应的段就不会出现。

有两个版本，输出完全一样：`pulseline.py` 只需要 Python 3，`pulseline.sh` 需要 bash 和 jq。

## 快速安装

安装程序会查找 Claude Code、Copilot CLI 和 Codex CLI，并告诉你找到了哪些。它会把脚本放到 `~/.pulseline/`（Windows 上是 `C:\Users\<you>\.pulseline\`），然后给每个工具加上状态栏设置，其他设置都不动。

修改文件之前，它会在旁边存一份副本（`settings.json.bak-<date>`）。如果某个文件不是合法的 JSON，它就不会碰这个文件。你可以随时重新运行它，它会更新同一份设置，不会重复添加。

### Windows

最简单的办法：下载项目（[Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)），解压后双击 `install-windows.cmd`。

也可以把下面这行粘贴到 PowerShell 里：

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

如果你没有 Python 3，安装程序会提出用 `winget` 帮你装上。

### macOS

最简单的办法：下载 ZIP，解压后双击 `install-macos.command`。第一次运行时 macOS 可能会拦截它。如果被拦截，右键点击这个文件，选择 **Open**，然后再点一次 **Open**。

也可以把下面这行粘贴到终端里：

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

装好后，重启 Claude Code、Copilot CLI 或 Codex。状态栏会出现在终端底部。

## 手动安装

### 编辑前请先读这里

这些设置文件都是 JSON，一个小错误就可能让整个文件失效，或者让工具悄悄忽略你的状态栏。有四件事要注意：

1. 你的 `settings.json` 里多半已经有其他设置了。把 `statusLine` 块加在它们旁边，不要把整个文件覆盖掉。
2. `statusLine` 必须放在顶层，也就是最外层 `{ }` 的正下方。如果它跑到了 `env`、`permissions` 或 `extraKnownMarketplaces` 这样的其他块里面，就不会生效。
3. 各项之间要加逗号，但最后一项后面不要加。
4. 重启之前先检查一下文件（见[检查 settings.json](#检查-settingsjson)）。

下面是一个常见错误。`statusLine` 块跑到了 `extraKnownMarketplaces` 里面：

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

这时 Claude Code 会把 `statusLine` 当成一个插件市场，忽略它，并显示这条警告：

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

修复方法是先把另一个块关闭，再在同一层级加上 `statusLine`：

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

这里的 `//` 注释只是为了说明。JSON 不允许注释，所以别把它们写进你的文件。

### 第 1 步：复制脚本

创建 `~/.pulseline/` 文件夹（Windows 上是 `C:\Users\<you>\.pulseline\`），把 `pulseline.py` 复制进去。如果你没有 Python 3，但有 `bash` 和 `jq`，就改用 `pulseline.sh`。

### 第 2 步：选择命令

| 系统 | `command` 的值 |
|---|---|
| macOS / Linux，Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux，bash | `bash ~/.pulseline/pulseline.sh` |
| Windows，Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

Windows 上的几个小建议：

- 用正斜杠（`C:/Users/...`）。在 JSON 里反斜杠要写两遍（`C:\\Users\\...`），很容易忘。
- 写完整路径，不要用 `~`，因为不是所有地方都会展开 `~`。
- 如果路径里有空格，要在字符串里给路径加上引号：`"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`。

### 第 3a 步：Claude Code

打开 `~/.claude/settings.json`（Windows 上是 `C:\Users\<you>\.claude\settings.json`）。如果文件不存在，就新建一个，内容写 `{}`。然后加上：

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### 第 3b 步：GitHub Copilot CLI

打开 `~/.copilot/settings.json`（或 `COPILOT_HOME` 指定的文件夹）。Copilot 的自定义状态栏目前还是实验性功能，所以你还需要打开 `STATUS_LINE` 功能开关：

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

如果你已经有 `feature_flags.enabled` 列表，就把 `"STATUS_LINE"` 加进去，不要再新建一个。用 `copilot --experimental` 启动 Copilot，或者在 Copilot 里运行 `/experimental`，也可以。Copilot 在启动时读取这些开关，所以改完之后要重启它（`/restart`）。

### 第 3c 步：OpenAI Codex CLI

Codex 不运行自定义脚本，不过你可以在 `~/.codex/config.toml` 里打开它的内置项。这个文件是 TOML，不是 JSON：

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

如果文件里已经有 `[tui]` 段，就把 `status_line` 这一行放在它下面，不要再加第二个 `[tui]`。你也可以在 Codex 里用 `/statusline` 从菜单里选这些项。

### 第 4 步：重启并检查

重启工具。如果状态栏没有出现，请看看[故障排查](#故障排查)。

### 检查 settings.json

重启前先运行下面的命令。如果文件没问题，它会把内容原样打印出来。如果有问题，它会告诉你出错的行号和列号：

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

然后确认 `statusLine` 在顶层。下面这条命令应该会打印出你的命令。如果打印的是 `null`，说明这个块被嵌套在别的东西里面了：

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## 选项

Pulseline 会读取几个环境变量。在 Claude Code 里，最方便的设置位置是 `~/.claude/settings.json` 中的 `env` 块，它也和 `statusLine` 一样放在顶层：

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

在 Copilot CLI 里，请在 shell 配置文件中设置：在 `~/.zshrc` 或 `~/.bashrc` 中写 `export PULSELINE_HIDE=cost`，Windows 上用 `setx PULSELINE_HIDE cost`。

| 变量 | 作用 |
|---|---|
| `PULSELINE_HIDE` | 隐藏你列出的段，用逗号分隔：`branch`、`agent`、`vim`、`ctx`、`5h`、`7d`、`cache`、`cost`、`premium`、`diff` |
| `PULSELINE_NO_EMOJI=1` | 用文字标签（`ctx`、`5h`、`cost`…）代替 emoji，适合无法显示 emoji 的终端或字体 |
| `PULSELINE_HOME` | 告诉安装程序把脚本放在哪里（默认 `~/.pulseline`） |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | 如果你把工具的设置挪到了别处，用它告诉安装程序在哪里 |

## 缓存计时器的工作方式

`💾 cache 47m of 1h` 表示对话的提示缓存还有 47 分钟失效，总有效期是 1 小时。剩余时间不到 20% 时，数字会变成黄色。缓存失效后，你会看到红色的 `cold`，旁边还会显示你的下一条消息需要重新写入缓存的 token 数。

Claude Code 会为每个请求决定缓存的有效期。使用 Claude 订阅且还在套餐用量之内时，有效期是 1 小时。使用额外用量、API 密钥或云服务商时，或者设置了 `FORCE_PROMPT_CACHING_5M=1` 或 `promptCacheTtl: "5m"` 时，有效期是 5 分钟。写入 5 分钟缓存的费用是输入价格的 1.25 倍，写入 1 小时缓存是 2 倍；从缓存读取的费用是 0.1 倍或更低。详情见 [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime)。

Pulseline 使用 Claude Code 发送的 `prompt_cache` 数据（2.1.251 及以后的版本）。在更早的版本上，它会根据会话记录来估算计时。这个段只在 Claude Code 中出现。

## 故障排查

| 症状 | 解决方法 |
|---|---|
| 出现警告 `Invalid marketplace entry was ignored ... statusLine` | `statusLine` 在 `extraKnownMarketplaces` 里面。把它移到顶层（[见上面的例子](#编辑前请先读这里)）。 |
| 工具提示 settings.json 无效，或者忽略了你的全部设置 | 有个逗号或花括号放错了。[检查一下文件](#检查-settingsjson)，它会告诉你是哪一行。 |
| 状态栏没有出现，也没有报错 | 自己运行一下脚本：`echo '{}' \| python3 ~/.pulseline/pulseline.py`。你应该会看到两行。如果看到了，`statusLine` 多半是被嵌套在别的块里了，请确认它在顶层。 |
| Copilot CLI 什么都不显示 | 确认 `STATUS_LINE` 功能开关已经打开（或者用 `--experimental` 启动 Copilot），然后重启它。 |
| `jq: command not found` | 安装 `jq`，或者改用 Python 版本。 |
| Windows 上运行 `python` 会打开 Microsoft Store | 从 [python.org](https://www.python.org/downloads/) 安装 Python，勾选 *Add python.exe to PATH*，然后重新运行安装程序。 |
| emoji 显示成方块 | 设置 `PULSELINE_NO_EMOJI=1`，或者换一个支持 emoji 的字体。 |
| 把 settings.json 改坏了，想恢复原来的 | 安装程序每次运行时都会在文件旁边保存一份 `settings.json.bak-<date>` 副本。 |

## 卸载

1. 从 `~/.claude/settings.json` 和/或 `~/.copilot/settings.json` 中删除 `statusLine` 块。在 Copilot 中，如果没有别的东西需要，也可以把 `STATUS_LINE` 从 `feature_flags.enabled` 里去掉。
2. 对于 Codex，从 `~/.codex/config.toml` 中删除 `status_line` 这一行。
3. 删除 `~/.pulseline/` 文件夹，然后重启你的工具。

## 许可证

[MIT](../LICENSE)
