# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · [Español](README.es.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · **한국어**

AI 코딩 CLI를 위한, 터미널 너비에 맞춰 바뀌는 컬러 상태 표시줄입니다. 모델, 폴더, git 브랜치, 컨텍스트 창, 사용량 한도, 프롬프트 캐시 타이머, 세션 비용, 변경된 줄 수를 보여 줍니다.

| 도구 | 지원 |
|---|---|
| [Claude Code](https://claude.com/claude-code) | 완전 지원: Pulseline 스크립트를 실행합니다 |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Pulseline 스크립트를 실행합니다 (사용자 지정 상태 표시줄은 Copilot의 실험적 기능입니다) |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex는 사용자 지정 스크립트를 실행할 수 없으므로, 설치 프로그램이 가장 비슷한 기본 제공 항목을 켭니다 |

![Pulseline 미리 보기](../assets/pulseline-preview.png)
<sub>위에서부터: 넓은 터미널의 Claude Code, 좁은 터미널의 Claude Code, <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code> 사용 시, 그리고 GitHub Copilot CLI와 OpenAI Codex CLI. <a href="../assets/pulseline-preview.svg">벡터 버전 (SVG)</a></sub>

## 기능

| 세그먼트 | 표시 내용 |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | 현재 모델, 작업 폴더, git 브랜치 |
| 👾 `@agent` · `INSERT` | 활성 서브에이전트와 vim 모드 (Claude Code 전용, 있을 때만 표시) |
| 🧠 context | 컨텍스트 창 사용량. 막대, 백분율, `used/total` 토큰 수로 표시 |
| 🕔 5h · 📅 7d | Claude 구독의 사용량 한도와 각각 초기화되기까지 남은 시간 |
| 💾 cache | 프롬프트 캐시가 만료되기까지 남은 시간, 또는 `cold · 73k to rewrite` |
| 💰 cost | 세션 비용(USD)과 총 세션 시간 |
| 🎫 premium | 이번 세션에서 사용한 프리미엄 요청 수 (Copilot CLI) |
| 📝 +/- | 이번 세션에서 추가·삭제된 줄 수 |

- **색상:** 70% 미만은 초록, 70~89%는 노랑, 90% 이상은 빨강.
- **어떤 너비에도 맞춤:** 창이 좁아지면 세그먼트가 다음 줄로 넘어갑니다. 그래도 두 줄에 다 들어가지 않으면 막대가 먼저, 그다음 초기화 시간이 숨겨집니다.
- **제공되는 정보만 표시:** 도구가 알려 주지 않는 세그먼트(예: API 키를 쓸 때의 사용량 한도)는 그냥 생략됩니다.
- **동일한 두 가지 버전:** `pulseline.py`(Python 3, 추가 패키지 없음)와 `pulseline.sh`(bash + jq). 출력 결과는 같습니다.

## 빠른 설치 (원클릭)

설치 프로그램은 다음을 수행합니다.

1. Claude Code, Copilot CLI, Codex CLI 중 어떤 것이 설치되어 있는지 **감지**하고 결과를 알려 줍니다.
2. 스크립트를 `~/.pulseline/`(Windows: `C:\Users\<you>\.pulseline\`)에 한 번만 설치합니다.
3. 각 도구의 설정에 상태 표시줄 키**만** 추가하고 나머지는 그대로 둡니다. 변경하기 전에 항상 백업(`settings.json.bak-<date>`)을 저장하며, 올바른 JSON이 아닌 파일은 건드리지 않습니다.

다시 실행해도 안전합니다. 중복 항목을 추가하지 않고 같은 키를 업데이트합니다.

### Windows

**가장 쉬운 방법:** 저장소를 내려받아([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)) 압축을 풀고 **`install-windows.cmd`**를 더블클릭합니다.

또는 PowerShell에 다음을 붙여 넣습니다.

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Python 3가 없으면 설치 프로그램이 `winget`으로 설치하도록 제안합니다.

### macOS

**가장 쉬운 방법:** ZIP을 내려받아 압축을 풀고 **`install-macos.command`**를 더블클릭합니다. 처음에는 macOS가 실행을 차단할 수 있습니다. 이때는 파일을 오른쪽 클릭 → **Open** → **Open**(열기)을 선택하세요.

또는 터미널에 다음을 붙여 넣습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

그런 다음 **도구를 다시 시작**합니다(Claude Code, Copilot CLI 또는 Codex). 상태 표시줄은 터미널 맨 아래에 나타납니다.

## 수동 설치

### 편집하기 전에: 대부분의 오류를 막는 규칙

여기서 다루는 설정 파일은 모두 JSON입니다. 다음은 파일을 망가뜨리는(또는 도구가 아무 말 없이 상태 표시줄을 무시하게 만드는) 실수들입니다.

1. **덮어쓰지 말고 합치세요.** `settings.json`에는 이미 다른 설정이 있을 가능성이 높습니다. `statusLine` 블록은 그 옆에 추가하고, 파일 전체를 덮어쓰지 마세요.
2. **`statusLine`은 최상위에 둡니다.** 가장 바깥쪽 `{ }`의 직접적인 자식이어야 합니다. `env`, `permissions`, `extraKnownMarketplaces` 같은 다른 블록 안에 넣으면 **안 됩니다**.
3. **쉼표는 항목 사이에만 넣고, 마지막 항목 뒤에는 넣지 않습니다.**
4. **다시 시작하기 전에 파일을 확인하세요** ([settings.json 검증하기](#settingsjson-검증하기) 참고).

**잘못된 예** — `statusLine`이 `extraKnownMarketplaces` 안에 들어갔습니다.

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ 다른 블록 안
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

그러면 Claude Code는 `statusLine`을 플러그인 마켓플레이스로 읽고, 무시한 뒤 다음 경고를 표시합니다.

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

**올바른 예** — 먼저 다른 블록을 닫은 다음, `statusLine`을 그 형제로 추가합니다.

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← extraKnownMarketplaces를 닫고, 쉼표
  "statusLine": {                         // ✓ 최상위
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

(`//` 주석은 설명을 위한 것일 뿐입니다. JSON은 주석을 허용하지 않으니 복사하지 마세요.)

### 1단계: 스크립트 복사

`~/.pulseline/` 폴더(Windows: `C:\Users\<you>\.pulseline\`)를 만들고 그 안에 `pulseline.py`를 복사합니다. Python 3는 없지만 `bash`와 `jq`가 있다면 `pulseline.sh`를 대신 사용하세요.

### 2단계: 명령 고르기

| 시스템 | `command` 값 |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

Windows에서는:

- **슬래시**(`C:/Users/...`)를 사용하세요. JSON에서 백슬래시는 두 번 써야 하며(`C:\\Users\\...`), 이를 잊는 것이 흔한 실수입니다.
- `~`는 모든 곳에서 확장되지 않으므로 대신 **전체 경로**를 사용하세요.
- 경로에 공백이 있으면 문자열 안에서 따옴표로 감싸세요: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### 3a단계: Claude Code

파일: `~/.claude/settings.json`(Windows: `C:\Users\<you>\.claude\settings.json`). 파일이 없으면 `{}`로 만드세요. 다음을 추가합니다.

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### 3b단계: GitHub Copilot CLI

파일: `~/.copilot/settings.json`(또는 `COPILOT_HOME`에 지정된 폴더). Copilot의 사용자 지정 상태 표시줄은 실험적 기능이므로 `STATUS_LINE` 기능 플래그도 필요합니다.

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

`feature_flags.enabled`가 이미 있다면 새로 만들지 말고 그 목록에 `"STATUS_LINE"`을 추가하세요. `copilot --experimental`로 Copilot을 시작하거나 Copilot 안에서 `/experimental`을 실행해도 됩니다. 그런 다음 Copilot을 다시 시작하세요(`/restart`). 플래그는 시작할 때 읽힙니다.

### 3c단계: OpenAI Codex CLI

Codex는 사용자 지정 스크립트를 실행하지 않습니다. 기본 제공 항목을 `~/.codex/config.toml`(JSON이 아니라 TOML)에 추가하세요.

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

파일에 이미 `[tui]` 섹션이 있다면 `status_line` 줄을 그 아래에 넣고, `[tui]`를 하나 더 만들지 마세요. Codex 안에서 `/statusline`으로 항목을 대화형으로 고를 수도 있습니다.

### 4단계: 다시 시작하고 확인

도구를 다시 시작합니다. 상태 표시줄이 나타나지 않으면 [문제 해결](#문제-해결)을 참고하세요.

### settings.json 검증하기

다시 시작하기 전에 다음을 실행하세요. 파일이 올바르면 내용을 다시 출력하고, 그렇지 않으면 오류가 있는 줄과 열을 알려 줍니다.

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

그다음 `statusLine`이 최상위에 있는지 확인합니다. 아래 명령은 여러분의 명령을 출력해야 합니다. `null`이 출력되면 블록이 다른 곳에 중첩되어 있는 것입니다.

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## 옵션

다음 항목은 환경 변수로 설정합니다. Claude Code에서는 `~/.claude/settings.json`의 `env` 블록(`statusLine`처럼 최상위 블록)에 넣는 것이 가장 쉽습니다.

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

Copilot CLI에서는 셸 프로필에서 설정하세요(`~/.zshrc` / `~/.bashrc`에 `export PULSELINE_HIDE=cost`, Windows에서는 `setx PULSELINE_HIDE cost`).

| 변수 | 효과 |
|---|---|
| `PULSELINE_HIDE` | 숨길 세그먼트를 쉼표로 구분해 지정: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | 이모지 대신 텍스트 라벨 사용(`ctx`, `5h`, `cost`…). 이모지를 표시하지 못하는 터미널이나 글꼴용 |
| `PULSELINE_HOME` | 설치 프로그램: 스크립트를 둘 위치 (기본값 `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | 설치 프로그램: 도구의 설정 폴더가 기본 위치에 없을 때 그 경로 |

## 캐시 표시기에 대해

`💾 cache 47m of 1h`는 대화의 프롬프트 캐시가 만료되기까지 남은 시간과 현재 사용 중인 TTL입니다. TTL이 20% 미만으로 남으면 노란색으로 바뀌고, 만료되면 빨간색으로 `cold`를 표시하며 다음 메시지가 캐시에 다시 기록할 토큰 수를 함께 보여 줍니다.

Claude Code는 요청마다 TTL을 고릅니다. 플랜 사용량 안에서 Claude 구독을 쓰면 **1시간**, 추가 사용량이나 API 키, 클라우드 제공업체를 쓰거나 `FORCE_PROMPT_CACHING_5M=1` / `promptCacheTtl: "5m"`이 설정되어 있으면 **5분**입니다. 5분 캐시에 쓰는 비용은 입력 가격의 1.25배, 1시간 캐시는 2배이며, 캐시 읽기는 0.1배 이하입니다. [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime)을 참고하세요.

스크립트는 Claude Code 자체의 `prompt_cache` 데이터(v2.1.251+)를 읽고, 이전 버전에서는 세션 트랜스크립트를 바탕으로 추정합니다. 이 세그먼트는 Claude Code 전용입니다.

## 문제 해결

| 증상 | 해결 방법 |
|---|---|
| `Invalid marketplace entry was ignored ... statusLine` 경고 | `statusLine`이 `extraKnownMarketplaces` 안에 중첩되어 있습니다. 최상위로 옮기세요 ([위 내용 참고](#편집하기-전에-대부분의-오류를-막는-규칙)). |
| 도구가 settings.json이 올바르지 않다고 하거나 모든 설정을 무시함 | 쉼표나 중괄호가 잘못되었습니다. [파일을 검증](#settingsjson-검증하기)하면 오류가 있는 줄이 표시됩니다. |
| 오류 없이 상태 표시줄이 나타나지 않음 | 스크립트를 직접 실행해 보세요: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. 두 줄이 출력되어야 합니다. 출력된다면 `statusLine`이 중첩되어 있을 가능성이 높으니 최상위에 있는지 확인하세요. |
| Copilot CLI에 아무것도 표시되지 않음 | `STATUS_LINE` 기능 플래그를 확인하고(또는 `--experimental`로 시작하고) Copilot을 다시 시작하세요. |
| `jq: command not found` | `jq`를 설치하거나 Python 버전으로 바꾸세요. |
| Windows: `python`을 실행하면 Microsoft Store가 열림 | [python.org](https://www.python.org/downloads/)에서 Python을 설치하고(*Add python.exe to PATH* 체크) 설치 프로그램을 다시 실행하세요. |
| 이모지 대신 네모가 보임 | `PULSELINE_NO_EMOJI=1`을 설정하거나 이모지를 지원하는 글꼴을 사용하세요. |
| settings.json을 망가뜨려서 되돌리고 싶음 | 설치 프로그램은 실행할 때마다 같은 위치에 `settings.json.bak-<date>`를 저장합니다. |

## 제거

1. `~/.claude/settings.json` 및/또는 `~/.copilot/settings.json`에서 `statusLine` 블록을 삭제합니다 (다른 용도로 쓰지 않는다면 Copilot의 `feature_flags.enabled`에서 `STATUS_LINE`도 삭제합니다).
2. Codex의 경우 `~/.codex/config.toml`에서 `status_line` 줄을 삭제합니다.
3. `~/.pulseline/` 폴더를 삭제하고 도구를 다시 시작합니다.

## 라이선스

[MIT](../LICENSE)
