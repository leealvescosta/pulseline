# Pulseline

[English](../README.md) · **Português** · [Español](README.es.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [한국어](README.ko.md)

Uma linha de status colorida e que se adapta à largura do terminal para CLIs de programação com IA: modelo, pasta, branch do git, janela de contexto, limites de uso, timer do cache de prompt, custo da sessão e linhas alteradas.

| Ferramenta | Suporte |
|---|---|
| [Claude Code](https://claude.com/claude-code) | Completo: executa o script do Pulseline |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Executa o script do Pulseline (a linha de status personalizada é um recurso experimental do Copilot) |
| [OpenAI Codex CLI](https://github.com/openai/codex) | O Codex não executa scripts personalizados, então o instalador ativa os itens nativos mais próximos |

![Prévia do Pulseline](../assets/pulseline-preview.png)
<sub>De cima para baixo: Claude Code em terminal largo, em terminal estreito, com <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code>, depois GitHub Copilot CLI e OpenAI Codex CLI. <a href="../assets/pulseline-preview.svg">Versão vetorial (SVG)</a>.</sub>

## Recursos

| Segmento | O que mostra |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | Modelo atual, pasta de trabalho e branch do git |
| 👾 `@agent` · `INSERT` | Subagente ativo e modo vim (Claude Code, só quando existem) |
| 🧠 context | Uso da janela de contexto, como barra, porcentagem e tokens `used/total` |
| 🕔 5h · 📅 7d | Limites de uso da assinatura do Claude e o tempo até cada um ser renovado |
| 💾 cache | Tempo até o cache de prompt esfriar, ou `cold · 73k to rewrite` |
| 💰 cost | Custo da sessão em USD e tempo total da sessão |
| 🎫 premium | Requisições premium usadas na sessão (Copilot CLI) |
| 📝 +/- | Linhas adicionadas e removidas nesta sessão |

- **Cores:** verde abaixo de 70%, amarelo de 70 a 89%, vermelho a partir de 90%.
- **Cabe em qualquer largura:** os segmentos quebram para uma nova linha conforme a janela fica mais estreita. Se ainda assim não couberem em duas linhas, as barras e depois os horários de renovação são ocultados.
- **Só o que está disponível:** um segmento que a ferramenta não informa (por exemplo, limites de uso com uma chave de API) simplesmente fica de fora.
- **Duas versões equivalentes:** `pulseline.py` (Python 3, sem pacotes) e `pulseline.sh` (bash + jq). As duas imprimem a mesma coisa.

## Instalação rápida (um clique)

O instalador:

1. **Detecta** quais destas ferramentas você tem (Claude Code, Copilot CLI e Codex CLI) e informa o que encontrou.
2. Instala o script uma única vez em `~/.pulseline/` (Windows: `C:\Users\<you>\.pulseline\`).
3. Adiciona **apenas** as chaves da linha de status às configurações de cada ferramenta, mantendo todo o resto. Um backup (`settings.json.bak-<date>`) é salvo antes de qualquer alteração, e um arquivo que não seja JSON válido não é tocado.

Rodar de novo é seguro: ele atualiza as mesmas chaves em vez de criar duplicatas.

### Windows

**Mais fácil:** baixe o repositório ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)), descompacte e dê um duplo clique em **`install-windows.cmd`**.

Ou cole isto no PowerShell:

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Se o Python 3 não estiver instalado, o instalador oferece instalá-lo com o `winget`.

### macOS

**Mais fácil:** baixe o ZIP, descompacte e dê um duplo clique em **`install-macos.command`**. Na primeira vez, o macOS pode bloqueá-lo: clique com o botão direito no arquivo → **Open** → **Open**.

Ou cole isto no Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

Depois, **reinicie a ferramenta** (Claude Code, Copilot CLI ou Codex). A linha de status aparece na parte de baixo do terminal.

## Instalação manual

### Antes de editar: as regras que evitam a maioria dos erros

Todos os arquivos de configuração aqui são JSON. Estes são os erros que os quebram (ou que fazem a ferramenta ignorar sua linha de status sem avisar):

1. **Mescle, não substitua.** Seu `settings.json` provavelmente já tem outras configurações. Adicione o bloco `statusLine` ao lado delas; não cole por cima do arquivo inteiro.
2. **`statusLine` fica no nível superior**, como filho direto do `{ }` mais externo. Ele **não** pode ficar dentro de outro bloco, como `env`, `permissions` ou `extraKnownMarketplaces`.
3. **As vírgulas vão entre os itens, nunca depois do último.**
4. **Verifique o arquivo antes de reiniciar** (veja [Valide seu settings.json](#valide-seu-settingsjson)).

**Errado** — o `statusLine` foi parar dentro de `extraKnownMarketplaces`:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ dentro de outro bloco
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

O Claude Code então lê o `statusLine` como um marketplace de plugins, ignora e mostra o aviso:

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

**Certo** — feche o outro bloco primeiro e depois adicione o `statusLine` como irmão dele:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← fecha extraKnownMarketplaces, depois uma vírgula
  "statusLine": {                         // ✓ nível superior
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

(Os comentários `//` estão aí só para explicar; JSON não aceita comentários, então não os copie.)

### Passo 1: copie o script

Crie a pasta `~/.pulseline/` (Windows: `C:\Users\<you>\.pulseline\`) e copie o `pulseline.py` para ela. Use o `pulseline.sh` se você não tiver Python 3 mas tiver `bash` e `jq`.

### Passo 2: escolha o seu comando

| Sistema | Valor de `command` |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

No Windows:

- Use **barras normais** (`C:/Users/...`). Barras invertidas em JSON precisam ser duplicadas (`C:\\Users\\...`), e esquecer isso é um erro comum.
- Use o **caminho completo** em vez de `~`, que não é expandido em todo lugar.
- Se o caminho tiver espaços, coloque-o entre aspas dentro da string: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### Passo 3a: Claude Code

Arquivo: `~/.claude/settings.json` (Windows: `C:\Users\<you>\.claude\settings.json`). Se ele não existir, crie-o com `{}`. Adicione:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### Passo 3b: GitHub Copilot CLI

Arquivo: `~/.copilot/settings.json` (ou a pasta definida em `COPILOT_HOME`). A linha de status personalizada do Copilot é experimental, então ela também precisa da feature flag `STATUS_LINE`:

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

Se `feature_flags.enabled` já existir, adicione `"STATUS_LINE"` a essa lista em vez de criar uma segunda. Você também pode iniciar o Copilot com `copilot --experimental` ou rodar `/experimental` dentro dele. Depois, reinicie o Copilot (`/restart`): as flags são lidas na inicialização.

### Passo 3c: OpenAI Codex CLI

O Codex não executa scripts personalizados. Adicione os itens nativos dele ao `~/.codex/config.toml` (TOML, não JSON):

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Se o arquivo já tiver uma seção `[tui]`, coloque a linha `status_line` dentro dela; não crie um segundo `[tui]`. Você também pode escolher os itens de forma interativa com `/statusline` dentro do Codex.

### Passo 4: reinicie e confira

Reinicie a ferramenta. Se a linha de status não aparecer, veja [Solução de problemas](#solução-de-problemas).

### Valide seu settings.json

Rode isto antes de reiniciar. O comando imprime o arquivo de volta se ele for válido, ou a linha e a coluna do erro:

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

Depois, confira se o `statusLine` está no nível superior. Isto precisa imprimir o seu comando; se imprimir `null`, o bloco está aninhado em outro lugar:

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## Opções

Defina estas variáveis de ambiente. No Claude Code, o lugar mais fácil é o bloco `env` do `~/.claude/settings.json` (um bloco de nível superior, como o `statusLine`):

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

No Copilot CLI, defina-as no perfil do seu shell (`export PULSELINE_HIDE=cost` no `~/.zshrc` / `~/.bashrc`, ou `setx PULSELINE_HIDE cost` no Windows).

| Variável | Efeito |
|---|---|
| `PULSELINE_HIDE` | Segmentos a ocultar, separados por vírgula: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | Rótulos em texto no lugar dos emojis (`ctx`, `5h`, `cost`…), para terminais ou fontes que não desenham emojis |
| `PULSELINE_HOME` | Instalador: onde colocar o script (padrão `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | Instalador: a pasta de configuração da sua ferramenta, se ela não estiver no lugar padrão |

## Sobre o indicador de cache

`💾 cache 47m of 1h` é o tempo que falta para o cache de prompt da conversa expirar, junto com o TTL em uso. Ele fica amarelo quando resta menos de 20% do TTL e mostra `cold` em vermelho depois que expira, com quantos tokens a próxima mensagem vai gravar no cache de novo.

O Claude Code escolhe o TTL a cada requisição: **1 hora** numa assinatura do Claude dentro do uso do plano, **5 minutos** com uso extra, chave de API ou provedor de nuvem, ou quando `FORCE_PROMPT_CACHING_5M=1` / `promptCacheTtl: "5m"` está definido. Gravar no cache de 5 minutos custa 1,25× o preço de entrada e no de 1 hora, 2×; leituras do cache custam 0,1× ou menos. Veja [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime).

O script lê os dados `prompt_cache` do próprio Claude Code (v2.1.251+); em versões mais antigas, ele faz uma estimativa a partir da transcrição da sessão. Este segmento é exclusivo do Claude Code.

## Solução de problemas

| Sintoma | Solução |
|---|---|
| Aviso `Invalid marketplace entry was ignored ... statusLine` | O `statusLine` está aninhado dentro de `extraKnownMarketplaces`. Mova-o para o nível superior ([veja acima](#antes-de-editar-as-regras-que-evitam-a-maioria-dos-erros)). |
| A ferramenta diz que o settings.json é inválido, ou ignora todas as suas configurações | Há uma vírgula ou chave errada. [Valide o arquivo](#valide-seu-settingsjson); o erro mostra a linha. |
| A linha de status não aparece e não há erro | Rode o script na mão: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. Ele deve imprimir duas linhas. Se imprimir, o `statusLine` provavelmente está aninhado: confira se ele está no nível superior. |
| O Copilot CLI não mostra nada | Confira a feature flag `STATUS_LINE` (ou inicie com `--experimental`) e reinicie o Copilot. |
| `jq: command not found` | Instale o `jq` ou mude para a versão em Python. |
| Windows: `python` abre a Microsoft Store | Instale o Python pelo [python.org](https://www.python.org/downloads/) (marque *Add python.exe to PATH*) e rode o instalador de novo. |
| Quadrados no lugar dos emojis | Defina `PULSELINE_NO_EMOJI=1` ou use uma fonte com suporte a emojis. |
| Você quebrou o settings.json e quer recuperá-lo | Cada execução do instalador salva um `settings.json.bak-<date>` ao lado dele. |

## Desinstalação

1. Remova o bloco `statusLine` do `~/.claude/settings.json` e/ou do `~/.copilot/settings.json` (e o `STATUS_LINE` de `feature_flags.enabled` do Copilot, se você não o usa para mais nada).
2. No Codex, remova a linha `status_line` do `~/.codex/config.toml`.
3. Apague a pasta `~/.pulseline/` e reinicie suas ferramentas.

## Licença

[MIT](../LICENSE)
