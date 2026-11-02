# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · [Español](README.es.md) · **日本語** · [简体中文](README.zh-CN.md) · [한국어](README.ko.md)

AI コーディング CLI 向けの、カラフルでターミナル幅に合わせて表示が変わるステータスラインです。モデル、フォルダ、git ブランチ、コンテキストウィンドウ、使用量の上限、プロンプトキャッシュのタイマー、セッションのコスト、変更行数を表示します。

| ツール | 対応状況 |
|---|---|
| [Claude Code](https://claude.com/claude-code) | 完全対応: Pulseline のスクリプトを実行します |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Pulseline のスクリプトを実行します(カスタムステータスラインは Copilot の実験的機能です) |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex はカスタムスクリプトを実行できないため、インストーラーが最も近い組み込み項目を有効にします |

![Pulseline のプレビュー](../assets/pulseline-preview.png)
<sub>上から順に：広いターミナルの Claude Code、狭いターミナルの Claude Code、<code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code> 使用時、GitHub Copilot CLI、OpenAI Codex CLI。<a href="../assets/pulseline-preview.svg">ベクター版 (SVG)</a></sub>

## 機能

| セグメント | 表示内容 |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | 現在のモデル、作業フォルダ、git ブランチ |
| 👾 `@agent` · `INSERT` | 実行中のサブエージェントと vim モード(Claude Code のみ、該当する場合だけ表示) |
| 🧠 context | コンテキストウィンドウの使用量。バー、パーセンテージ、`used/total` トークン数で表示 |
| 🕔 5h · 📅 7d | Claude サブスクリプションの使用量の上限と、それぞれがリセットされるまでの時間 |
| 💾 cache | プロンプトキャッシュが切れるまでの時間、または `cold · 73k to rewrite` |
| 💰 cost | セッションのコスト(USD)とセッションの合計時間 |
| 🎫 premium | このセッションで使ったプレミアムリクエスト数(Copilot CLI) |
| 📝 +/- | このセッションで追加・削除された行数 |

- **色:** 70% 未満は緑、70〜89% は黄、90% 以上は赤。
- **どんな幅にも収まる:** ウィンドウが狭くなるとセグメントは次の行に折り返されます。それでも 2 行に収まらない場合は、まずバー、次にリセット時刻が非表示になります。
- **取得できるものだけ表示:** ツールが報告しないセグメント(たとえば API キー利用時の使用量の上限)は表示されません。
- **同等の 2 つのバージョン:** `pulseline.py`(Python 3、追加パッケージ不要)と `pulseline.sh`(bash + jq)。出力は同じです。

## クイックインストール(ワンクリック)

インストーラーは次のことを行います。

1. Claude Code、Copilot CLI、Codex CLI のうちどれがインストールされているかを**検出**し、見つかったものを知らせます。
2. スクリプトを `~/.pulseline/`(Windows: `C:\Users\<you>\.pulseline\`)に一度だけインストールします。
3. 各ツールの設定にステータスラインのキー**だけ**を追加し、それ以外はそのまま残します。変更前には必ずバックアップ(`settings.json.bak-<date>`)が保存され、有効な JSON でないファイルには手を付けません。

何度実行しても安全です。重複を追加せず、同じキーを更新します。

### Windows

**いちばん簡単な方法:** リポジトリをダウンロードし([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip))、展開して **`install-windows.cmd`** をダブルクリックします。

または、PowerShell に次を貼り付けます。

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Python 3 が入っていない場合は、インストーラーが `winget` でのインストールを提案します。

### macOS

**いちばん簡単な方法:** ZIP をダウンロードして展開し、**`install-macos.command`** をダブルクリックします。初回は macOS にブロックされることがあります。その場合はファイルを右クリック → **Open** → **Open**(開く)を選びます。

または、ターミナルに次を貼り付けます。

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

その後、**ツールを再起動**します(Claude Code、Copilot CLI、または Codex)。ステータスラインはターミナルの下部に表示されます。

## 手動インストール

### 編集する前に: ほとんどのエラーを防ぐルール

ここで扱う設定ファイルはすべて JSON です。以下は、ファイルを壊してしまう(あるいはツールが何も言わずにステータスラインを無視してしまう)よくある間違いです。

1. **置き換えずにマージする。** `settings.json` にはおそらくすでにほかの設定があります。`statusLine` ブロックはそれらと並べて追加し、ファイル全体を上書きしないでください。
2. **`statusLine` はトップレベルに置く。** いちばん外側の `{ }` の直接の子にします。`env`、`permissions`、`extraKnownMarketplaces` などほかのブロックの中に入れては**いけません**。
3. **カンマは項目と項目の間に置き、最後の項目の後には付けない。**
4. **再起動する前にファイルを確認する**([settings.json を検証する](#settingsjson-を検証する)を参照)。

**誤り** — `statusLine` が `extraKnownMarketplaces` の中に入ってしまっています。

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ ほかのブロックの中
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

すると Claude Code は `statusLine` をプラグインのマーケットプレイスとして読み込み、無視したうえで次の警告を出します。

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

**正しい例** — 先にほかのブロックを閉じてから、`statusLine` をその兄弟として追加します。

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← extraKnownMarketplaces を閉じて、カンマ
  "statusLine": {                         // ✓ トップレベル
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

(`//` のコメントは説明のためだけのものです。JSON ではコメントが使えないので、コピーしないでください。)

### ステップ 1: スクリプトをコピーする

`~/.pulseline/` フォルダ(Windows: `C:\Users\<you>\.pulseline\`)を作り、そこに `pulseline.py` をコピーします。Python 3 がなく、`bash` と `jq` がある場合は、代わりに `pulseline.sh` を使ってください。

### ステップ 2: コマンドを選ぶ

| システム | `command` の値 |
|---|---|
| macOS / Linux、Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux、bash | `bash ~/.pulseline/pulseline.sh` |
| Windows、Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

Windows の場合:

- **スラッシュ**(`C:/Users/...`)を使います。JSON の中のバックスラッシュは二重にする必要があり(`C:\\Users\\...`)、これを忘れるのはよくある間違いです。
- `~` はどこでも展開されるわけではないので、代わりに**フルパス**を使います。
- パスにスペースが含まれる場合は、文字列の中で引用符で囲みます: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`。

### ステップ 3a: Claude Code

ファイル: `~/.claude/settings.json`(Windows: `C:\Users\<you>\.claude\settings.json`)。存在しない場合は `{}` だけのファイルを作ります。次を追加します。

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### ステップ 3b: GitHub Copilot CLI

ファイル: `~/.copilot/settings.json`(または `COPILOT_HOME` で指定したフォルダ)。Copilot のカスタムステータスラインは実験的機能なので、`STATUS_LINE` フィーチャーフラグも必要です。

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

`feature_flags.enabled` がすでにある場合は、2 つ目を作らずにそのリストへ `"STATUS_LINE"` を追加します。`copilot --experimental` で Copilot を起動するか、Copilot の中で `/experimental` を実行しても構いません。その後 Copilot を再起動してください(`/restart`)。フラグは起動時に読み込まれます。

### ステップ 3c: OpenAI Codex CLI

Codex はカスタムスクリプトを実行しません。組み込みの項目を `~/.codex/config.toml`(JSON ではなく TOML)に追加します。

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

ファイルにすでに `[tui]` セクションがある場合は、その下に `status_line` の行を入れます。`[tui]` を 2 つ作らないでください。Codex の中で `/statusline` を使って対話的に項目を選ぶこともできます。

### ステップ 4: 再起動して確認する

ツールを再起動します。ステータスラインが表示されない場合は、[トラブルシューティング](#トラブルシューティング)を参照してください。

### settings.json を検証する

再起動する前に次を実行します。ファイルが有効ならその内容が表示され、そうでなければエラーの行と列が表示されます。

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

次に、`statusLine` がトップレベルにあることを確認します。以下を実行するとコマンドが表示されるはずです。`null` と表示された場合、ブロックはどこか別の場所に入れ子になっています。

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## オプション

これらは環境変数として設定します。Claude Code では、`~/.claude/settings.json` の `env` ブロック(`statusLine` と同じくトップレベルのブロック)に書くのがいちばん簡単です。

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

Copilot CLI では、シェルのプロファイルで設定します(`~/.zshrc` / `~/.bashrc` に `export PULSELINE_HIDE=cost`、Windows では `setx PULSELINE_HIDE cost`)。

| 変数 | 効果 |
|---|---|
| `PULSELINE_HIDE` | 非表示にするセグメントをカンマ区切りで指定: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | 絵文字の代わりにテキストラベルを表示(`ctx`、`5h`、`cost`…)。絵文字を表示できないターミナルやフォント向け |
| `PULSELINE_HOME` | インストーラー: スクリプトを置く場所(デフォルトは `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | インストーラー: ツールの設定フォルダがデフォルトの場所にない場合のパス |

## キャッシュ表示について

`💾 cache 47m of 1h` は、会話のプロンプトキャッシュが期限切れになるまでの残り時間と、使用中の TTL を表します。残りが TTL の 20% を切ると黄色になり、期限が切れると赤で `cold` と表示され、次のメッセージでキャッシュに書き直されるトークン数も示されます。

Claude Code はリクエストごとに TTL を選びます。プランの使用量内で Claude サブスクリプションを使っている場合は **1 時間**、追加使用量、API キー、クラウドプロバイダーを使っている場合や、`FORCE_PROMPT_CACHING_5M=1` / `promptCacheTtl: "5m"` が設定されている場合は **5 分** です。5 分キャッシュへの書き込みには入力価格の 1.25 倍、1 時間キャッシュへの書き込みには 2 倍のコストがかかり、キャッシュの読み込みは 0.1 倍以下です。詳しくは [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime) を参照してください。

スクリプトは Claude Code 自身の `prompt_cache` データ(v2.1.251 以降)を読み取ります。それより古いバージョンでは、セッションのトランスクリプトから推定します。このセグメントは Claude Code 専用です。

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| `Invalid marketplace entry was ignored ... statusLine` という警告が出る | `statusLine` が `extraKnownMarketplaces` の中に入れ子になっています。トップレベルに移動してください([上記を参照](#編集する前に-ほとんどのエラーを防ぐルール))。 |
| ツールが settings.json を無効だと言う、またはすべての設定を無視する | カンマか波かっこが間違っています。[ファイルを検証](#settingsjson-を検証する)すると、エラーの行が表示されます。 |
| エラーは出ないがステータスラインが表示されない | スクリプトを手動で実行します: `echo '{}' \| python3 ~/.pulseline/pulseline.py`。2 行出力されるはずです。出力される場合、`statusLine` が入れ子になっている可能性が高いので、トップレベルにあるか確認してください。 |
| Copilot CLI に何も表示されない | `STATUS_LINE` フィーチャーフラグを確認し(または `--experimental` で起動し)、Copilot を再起動します。 |
| `jq: command not found` | `jq` をインストールするか、Python 版に切り替えます。 |
| Windows: `python` で Microsoft Store が開く | [python.org](https://www.python.org/downloads/) から Python をインストールし(*Add python.exe to PATH* にチェック)、インストーラーをもう一度実行します。 |
| 絵文字の代わりに四角が表示される | `PULSELINE_NO_EMOJI=1` を設定するか、絵文字に対応したフォントを使います。 |
| settings.json を壊してしまい、元に戻したい | インストーラーは実行のたびに、同じ場所に `settings.json.bak-<date>` を保存しています。 |

## アンインストール

1. `~/.claude/settings.json` と `~/.copilot/settings.json` から `statusLine` ブロックを削除します(ほかに使っていなければ、Copilot の `feature_flags.enabled` から `STATUS_LINE` も削除します)。
2. Codex の場合は、`~/.codex/config.toml` から `status_line` の行を削除します。
3. `~/.pulseline/` フォルダを削除し、ツールを再起動します。

## ライセンス

[MIT](../LICENSE)
