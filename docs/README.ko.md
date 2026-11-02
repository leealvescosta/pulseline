# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · [Español](README.es.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · **한국어**

Pulseline은 터미널에서 쓰는 AI 코딩 도구를 위한 컬러 상태 표시줄입니다. 모델, 폴더, git 브랜치, 컨텍스트 창이 얼마나 찼는지, 사용량 한도를 얼마나 썼는지, 프롬프트 캐시가 언제 식는지, 세션 비용이 얼마인지, 몇 줄을 바꿨는지 보여 줍니다. 터미널 너비에 맞춰 알아서 바뀝니다.

| 도구 | 지원 |
|---|---|
| [Claude Code](https://claude.com/claude-code) | 완전 지원. Pulseline 스크립트를 실행합니다. |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Pulseline 스크립트를 실행합니다. 사용자 지정 상태 표시줄은 아직 Copilot의 실험적 기능입니다. |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex는 사용자 지정 스크립트를 실행할 수 없어서, 설치 프로그램이 가장 비슷한 기본 제공 항목을 대신 켭니다. |

![Pulseline 미리 보기](../assets/pulseline-preview.png)
<sub>위에서부터: 넓은 터미널의 Claude Code, 좁은 터미널의 Claude Code, <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code> 사용 시, 그리고 GitHub Copilot CLI와 OpenAI Codex CLI. <a href="../assets/pulseline-preview.svg">벡터 버전 (SVG)</a></sub>

## 표시하는 내용

| 세그먼트 | 표시하는 내용 |
|---|---|
| 🤖 모델 · 📁 폴더 · 🌿 브랜치 | 현재 모델, 작업 폴더, git 브랜치 |
| 👾 `@agent` · `INSERT` | 활성 서브에이전트와 vim 모드 (Claude Code에서 사용 중일 때) |
| 🧠 컨텍스트 | 컨텍스트 창을 얼마나 쓰고 있는지 막대, 퍼센트, `used/total` 토큰 수로 보여 줍니다 |
| 🕔 5h · 📅 7d | Claude 구독 한도와 각 한도가 초기화되기까지 남은 시간 |
| 💾 캐시 | 프롬프트 캐시가 식기까지 남은 시간, 식은 뒤에는 `cold · 73k to rewrite` |
| 💰 비용 | 세션 비용 (USD)과 세션이 실행된 시간 |
| 🎫 premium | 세션에서 사용한 프리미엄 요청 수 (Copilot CLI) |
| 📝 +/- | 이번 세션에서 추가하고 삭제한 줄 수 |

숫자는 70% 미만이면 초록색, 70~89%면 노란색, 90% 이상이면 빨간색입니다.

창이 좁아지면 세그먼트가 다음 줄로 넘어갑니다. 두 줄로도 모자라면 Pulseline은 막대를 먼저 숨기고, 그다음 초기화 시간을 숨깁니다.

도구가 어떤 정보를 알려 주지 않으면 (예를 들어 API 키를 쓸 때의 사용량 한도), 그 세그먼트는 그냥 나타나지 않습니다.

출력이 완전히 같은 두 가지 버전이 있습니다. `pulseline.py`는 Python 3만 있으면 되고, `pulseline.sh`는 bash와 jq가 필요합니다.

## 빠른 설치

설치 프로그램은 Claude Code, Copilot CLI, Codex CLI를 찾아보고 어떤 것을 찾았는지 알려 줍니다. 스크립트를 `~/.pulseline/` (Windows에서는 `C:\Users\<you>\.pulseline\`)에 넣은 다음, 각 도구에 상태 표시줄 설정을 추가합니다. 나머지 설정은 건드리지 않습니다.

파일을 바꾸기 전에 그 옆에 사본(`settings.json.bak-<date>`)을 저장합니다. 파일이 올바른 JSON이 아니면 그 파일은 건드리지 않습니다. 언제든 다시 실행해도 됩니다. 설정을 두 번 추가하지 않고 같은 설정을 업데이트합니다.

### Windows

가장 쉬운 방법은 프로젝트를 내려받아 ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)) 압축을 풀고 `install-windows.cmd`를 더블클릭하는 것입니다.

PowerShell에 아래 내용을 붙여 넣어도 됩니다.

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Python 3가 없으면 설치 프로그램이 `winget`으로 설치해 주겠다고 물어봅니다.

### macOS

가장 쉬운 방법은 ZIP을 내려받아 압축을 풀고 `install-macos.command`를 더블클릭하는 것입니다. 처음 실행할 때 macOS가 막을 수 있습니다. 그러면 파일을 오른쪽 클릭하고 **Open**을 고른 뒤, **Open**을 한 번 더 누르세요.

터미널에 아래 내용을 붙여 넣어도 됩니다.

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

설치가 끝나면 Claude Code, Copilot CLI 또는 Codex를 다시 시작하세요. 터미널 아래쪽에 상태 표시줄이 나타납니다.

## 수동 설치

### 편집하기 전에 읽어 주세요

이 설정 파일들은 모두 JSON이라서, 작은 실수 하나로 파일 전체가 망가지거나 도구가 아무 말 없이 상태 표시줄을 무시할 수 있습니다. 네 가지를 기억해 두세요.

1. `settings.json`에는 아마 다른 설정이 이미 들어 있을 겁니다. 파일 위에 덮어 붙이지 말고, 그 옆에 `statusLine` 블록을 추가하세요.
2. `statusLine`은 최상위, 즉 가장 바깥쪽 `{ }` 바로 안에 있어야 합니다. `env`, `permissions`, `extraKnownMarketplaces` 같은 다른 블록 안에 들어가면 동작하지 않습니다.
3. 항목 사이에는 쉼표를 넣고, 마지막 항목 뒤에는 넣지 마세요.
4. 다시 시작하기 전에 파일을 확인하세요 ([settings.json 확인하기](#settingsjson-확인하기) 참고).

흔히 하는 실수입니다. `statusLine` 블록이 `extraKnownMarketplaces` 안에 들어가 버렸습니다.

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ 다른 블록 안에 있음
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

그러면 Claude Code는 `statusLine`을 플러그인 마켓플레이스로 생각하고 무시한 뒤 이런 경고를 보여 줍니다.

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

고치려면 다른 블록을 먼저 닫고, 그 뒤에 같은 수준으로 `statusLine`을 추가하세요.

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← extraKnownMarketplaces를 닫고 쉼표
  "statusLine": {                         // ✓ 최상위
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

`//` 주석은 설명하려고 넣은 것입니다. JSON은 주석을 허용하지 않으니 실제 파일에는 넣지 마세요.

### 1단계: 스크립트 복사하기

`~/.pulseline/` 폴더 (Windows에서는 `C:\Users\<you>\.pulseline\`)를 만들고 그 안에 `pulseline.py`를 복사하세요. Python 3는 없지만 `bash`와 `jq`가 있다면 `pulseline.sh`를 쓰면 됩니다.

### 2단계: 명령 고르기

| 시스템 | `command` 값 |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

Windows에서 알아 두면 좋은 점입니다.

- 슬래시(`C:/Users/...`)를 쓰세요. JSON에서는 백슬래시를 두 번 써야 하는데 (`C:\\Users\\...`), 깜빡하기 쉽습니다.
- `~`는 모든 곳에서 펼쳐지지 않으니, `~` 대신 전체 경로를 쓰세요.
- 경로에 공백이 있으면 문자열 안에서 경로를 따옴표로 감싸세요: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### 3a단계: Claude Code

`~/.claude/settings.json` (Windows에서는 `C:\Users\<you>\.claude\settings.json`)을 엽니다. 파일이 없으면 `{}`를 넣어서 만드세요. 그런 다음 아래 내용을 추가합니다.

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### 3b단계: GitHub Copilot CLI

`~/.copilot/settings.json` (또는 `COPILOT_HOME`에 지정한 폴더)을 엽니다. Copilot의 사용자 지정 상태 표시줄은 아직 실험적 기능이라서, `STATUS_LINE` 기능 플래그도 켜야 합니다.

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

이미 `feature_flags.enabled` 목록이 있다면 새로 만들지 말고 거기에 `"STATUS_LINE"`을 추가하세요. `copilot --experimental`로 Copilot을 시작하거나, Copilot 안에서 `/experimental`을 실행해도 됩니다. Copilot은 시작할 때 플래그를 읽으니, 바꾼 뒤에는 다시 시작하세요 (`/restart`).

### 3c단계: OpenAI Codex CLI

Codex는 사용자 지정 스크립트를 실행하지 않지만, `~/.codex/config.toml`에서 기본 제공 항목을 켤 수 있습니다. 이 파일은 JSON이 아니라 TOML입니다.

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

파일에 이미 `[tui]` 섹션이 있다면, 두 번째 `[tui]`를 추가하지 말고 그 아래에 `status_line` 줄을 넣으세요. Codex 안에서 `/statusline`을 실행하면 메뉴에서 항목을 고를 수도 있습니다.

### 4단계: 다시 시작하고 확인하기

도구를 다시 시작하세요. 상태 표시줄이 나타나지 않으면 [문제 해결](#문제-해결)을 살펴보세요.

### settings.json 확인하기

다시 시작하기 전에 이 명령을 실행하세요. 파일이 올바르면 내용을 그대로 출력합니다. 그렇지 않으면 문제가 있는 줄과 열을 알려 줍니다.

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

그다음 `statusLine`이 최상위에 있는지 확인하세요. 아래 명령은 여러분의 명령을 출력해야 합니다. `null`이 출력되면 블록이 다른 무언가 안에 들어가 있는 것입니다.

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## 옵션

Pulseline은 몇 가지 환경 변수를 읽습니다. Claude Code에서는 `~/.claude/settings.json`의 `env` 블록에 설정하는 게 가장 쉽습니다. 이 블록도 `statusLine`처럼 최상위에 둡니다.

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

Copilot CLI에서는 셸 프로필에 설정하세요. `~/.zshrc`나 `~/.bashrc`에 `export PULSELINE_HIDE=cost`를 넣거나, Windows에서는 `setx PULSELINE_HIDE cost`를 실행하면 됩니다.

| 변수 | 하는 일 |
|---|---|
| `PULSELINE_HIDE` | 나열한 세그먼트를 숨깁니다. 쉼표로 구분합니다: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | 이모지 대신 텍스트 라벨(`ctx`, `5h`, `cost`…)을 보여 줍니다. 이모지를 표시하지 못하는 터미널이나 글꼴용입니다 |
| `PULSELINE_HOME` | 설치 프로그램이 스크립트를 둘 위치를 알려 줍니다 (기본값 `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | 도구의 설정 위치를 옮겼다면, 그 위치를 설치 프로그램에 알려 줍니다 |

## 캐시 타이머의 동작 방식

`💾 cache 47m of 1h`는 대화의 프롬프트 캐시가 1시간의 수명 중 47분 뒤에 만료된다는 뜻입니다. 남은 시간이 20% 아래로 내려가면 숫자가 노란색으로 바뀝니다. 캐시가 만료되면 빨간색 `cold`가 보이고, 다음 메시지가 캐시에 다시 써야 하는 토큰 수도 함께 표시됩니다.

Claude Code는 요청마다 캐시 수명을 정합니다. Claude 구독을 쓰면서 플랜 사용량 안에 있을 때는 1시간입니다. 추가 사용량, API 키, 클라우드 제공업체를 쓸 때, 또는 `FORCE_PROMPT_CACHING_5M=1`이나 `promptCacheTtl: "5m"`을 설정했을 때는 5분입니다. 5분 캐시에 쓰는 비용은 입력 가격의 1.25배, 1시간 캐시에 쓰는 비용은 2배이고, 캐시에서 읽는 비용은 0.1배 이하입니다. 자세한 내용은 [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime)에 있습니다.

Pulseline은 Claude Code가 보내는 `prompt_cache` 데이터 (버전 2.1.251 이상)를 사용합니다. 그보다 오래된 버전에서는 세션 기록으로 타이머를 추정합니다. 이 세그먼트는 Claude Code에서만 나타납니다.

## 문제 해결

| 증상 | 해결 방법 |
|---|---|
| `Invalid marketplace entry was ignored ... statusLine` 경고가 나옴 | `statusLine`이 `extraKnownMarketplaces` 안에 있습니다. 최상위로 옮기세요 ([위 예시 참고](#편집하기-전에-읽어-주세요)). |
| 도구가 settings.json이 잘못되었다고 하거나, 설정을 전부 무시함 | 쉼표나 중괄호가 어긋나 있습니다. [파일을 확인하면](#settingsjson-확인하기) 문제가 있는 줄을 알려 줍니다. |
| 상태 표시줄이 나타나지 않고 오류도 없음 | 스크립트를 직접 실행해 보세요: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. 두 줄이 보여야 합니다. 보인다면 `statusLine`이 다른 블록 안에 들어가 있을 가능성이 높으니, 최상위에 있는지 확인하세요. |
| Copilot CLI에 아무것도 표시되지 않음 | `STATUS_LINE` 기능 플래그가 켜져 있는지 확인하고 (또는 `--experimental`로 Copilot을 시작하고), 다시 시작하세요. |
| `jq: command not found` | `jq`를 설치하거나 Python 버전을 쓰세요. |
| Windows에서 `python`을 실행하면 Microsoft Store가 열림 | [python.org](https://www.python.org/downloads/)에서 Python을 설치하고 *Add python.exe to PATH*를 체크한 뒤, 설치 프로그램을 다시 실행하세요. |
| 이모지 대신 네모가 보임 | `PULSELINE_NO_EMOJI=1`을 설정하거나 이모지를 지원하는 글꼴로 바꾸세요. |
| settings.json을 망가뜨려서 예전 파일로 되돌리고 싶음 | 설치 프로그램은 실행할 때마다 파일 옆에 `settings.json.bak-<date>` 사본을 저장합니다. |

## 제거

1. `~/.claude/settings.json` 및/또는 `~/.copilot/settings.json`에서 `statusLine` 블록을 지우세요. Copilot에서는 다른 곳에서 필요하지 않다면 `feature_flags.enabled`에서 `STATUS_LINE`을 빼도 됩니다.
2. Codex에서는 `~/.codex/config.toml`에서 `status_line` 줄을 지우세요.
3. `~/.pulseline/` 폴더를 지우고 도구를 다시 시작하세요.

## 라이선스

[MIT](../LICENSE)
