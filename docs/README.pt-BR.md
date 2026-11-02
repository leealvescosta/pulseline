# Pulseline

[English](../README.md) · **Português** · [Español](README.es.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [한국어](README.ko.md)

O Pulseline é uma linha de status colorida para ferramentas de programação com IA no terminal. Ela mostra o modelo, a pasta e a branch do git, o quanto a janela de contexto está cheia, quanto dos seus limites de uso você já gastou, quando o cache de prompt esfria, quanto a sessão custou e quantas linhas você alterou. Ela se ajusta à largura do terminal.

| Ferramenta | Suporte |
|---|---|
| [Claude Code](https://claude.com/claude-code) | Suporte completo. Executa o script do Pulseline. |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Executa o script do Pulseline. A linha de status personalizada ainda é um recurso experimental do Copilot. |
| [OpenAI Codex CLI](https://github.com/openai/codex) | O Codex não executa scripts personalizados, então o instalador ativa os itens nativos mais parecidos. |

![Prévia do Pulseline](../assets/pulseline-preview.png)
<sub>De cima para baixo: Claude Code em terminal largo, em terminal estreito, com <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code>, depois GitHub Copilot CLI e OpenAI Codex CLI. <a href="../assets/pulseline-preview.svg">Versão vetorial (SVG)</a>.</sub>

## O que ele mostra

| Segmento | O que mostra |
|---|---|
| 🤖 modelo · 📁 pasta · 🌿 branch | O modelo atual, a pasta de trabalho e a branch do git |
| 👾 `@agent` · `INSERT` | O subagente ativo e o modo do vim (no Claude Code, quando estão em uso) |
| 🧠 contexto | Quanto da janela de contexto está em uso, como barra, porcentagem e tokens `used/total` |
| 🕔 5h · 📅 7d | Os limites da sua assinatura do Claude e quanto falta para cada um zerar |
| 💾 cache | Quanto falta para o cache de prompt esfriar, ou `cold · 73k to rewrite` depois que esfriou |
| 💰 custo | Quanto a sessão custou em USD e há quanto tempo ela está rodando |
| 🎫 premium | Requisições premium usadas na sessão (Copilot CLI) |
| 📝 +/- | Linhas adicionadas e removidas nesta sessão |

Os números ficam verdes abaixo de 70%, amarelos de 70 a 89% e vermelhos a partir de 90%.

Quando a janela fica mais estreita, os segmentos passam para uma nova linha. Se duas linhas ainda não bastarem, o Pulseline esconde primeiro as barras e depois os horários de reset.

Se uma ferramenta não informa algum dado (os limites de uso quando você usa uma chave de API, por exemplo), esse segmento simplesmente não aparece.

Existem duas versões que imprimem exatamente a mesma coisa: `pulseline.py` precisa só do Python 3, e `pulseline.sh` precisa de bash e jq.

## Instalação rápida

O instalador procura o Claude Code, o Copilot CLI e o Codex CLI e avisa quais encontrou. Ele coloca o script em `~/.pulseline/` (no Windows, `C:\Users\<you>\.pulseline\`) e depois adiciona as configurações da linha de status em cada ferramenta, sem mexer no resto das suas configurações.

Antes de alterar um arquivo, ele salva uma cópia ao lado (`settings.json.bak-<date>`). Se um arquivo não for um JSON válido, ele não toca nele. Você pode rodar o instalador de novo quando quiser; ele atualiza as mesmas configurações em vez de adicioná-las duas vezes.

### Windows

O jeito mais fácil: baixe o projeto ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)), descompacte e dê dois cliques em `install-windows.cmd`.

Você também pode colar isto no PowerShell:

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Se você não tiver o Python 3, o instalador se oferece para instalá-lo com o `winget`.

### macOS

O jeito mais fácil: baixe o ZIP, descompacte e dê dois cliques em `install-macos.command`. O macOS pode bloquear o arquivo na primeira vez. Se isso acontecer, clique com o botão direito no arquivo, escolha **Open** e depois **Open** de novo.

Você também pode colar isto no Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

Quando terminar, reinicie o Claude Code, o Copilot CLI ou o Codex. A linha de status aparece na parte de baixo do terminal.

## Instalação manual

### Leia isto antes de editar

Todos esses arquivos de configuração são JSON, e um errinho pode quebrar o arquivo inteiro ou fazer a ferramenta ignorar sua linha de status sem avisar. Quatro coisas para ter em mente:

1. Seu `settings.json` provavelmente já tem outras configurações. Adicione o bloco `statusLine` ao lado delas em vez de colar por cima do arquivo.
2. O `statusLine` precisa ficar no nível principal, direto dentro das `{ }` mais externas. Se ele for parar dentro de outro bloco, como `env`, `permissions` ou `extraKnownMarketplaces`, não funciona.
3. Coloque uma vírgula entre os itens, mas não depois do último.
4. Confira o arquivo antes de reiniciar (veja [Confira seu settings.json](#confira-seu-settingsjson)).

Este é um erro comum. O bloco `statusLine` foi parar dentro de `extraKnownMarketplaces`:

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

Aí o Claude Code acha que `statusLine` é um marketplace de plugins, ignora o bloco e mostra este aviso:

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

Para corrigir, feche o outro bloco primeiro e adicione `statusLine` depois dele, no mesmo nível:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← fecha extraKnownMarketplaces, depois uma vírgula
  "statusLine": {                         // ✓ nível principal
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

Os comentários `//` estão aí só para explicar. JSON não aceita comentários, então deixe eles fora do seu arquivo.

### Passo 1: copie o script

Crie a pasta `~/.pulseline/` (no Windows, `C:\Users\<you>\.pulseline\`) e copie o `pulseline.py` para ela. Se você não tiver Python 3 mas tiver `bash` e `jq`, use o `pulseline.sh`.

### Passo 2: escolha o comando

| Sistema | Valor de `command` |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

Algumas dicas para o Windows:

- Use barras normais (`C:/Users/...`). Barras invertidas precisam ser duplicadas no JSON (`C:\\Users\\...`), e é fácil esquecer.
- Escreva o caminho completo em vez de `~`, porque o `~` não é expandido em todo lugar.
- Se o caminho tiver espaços, coloque aspas em volta dele dentro da string: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### Passo 3a: Claude Code

Abra `~/.claude/settings.json` (no Windows, `C:\Users\<you>\.claude\settings.json`). Se ele não existir, crie com `{}` dentro. Depois adicione:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### Passo 3b: GitHub Copilot CLI

Abra `~/.copilot/settings.json` (ou a pasta definida em `COPILOT_HOME`). A linha de status personalizada do Copilot ainda é experimental, então você também precisa ativar a feature flag `STATUS_LINE`:

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

Se você já tem uma lista `feature_flags.enabled`, adicione `"STATUS_LINE"` a ela em vez de criar uma segunda. Iniciar o Copilot com `copilot --experimental`, ou rodar `/experimental` dentro dele, também funciona. O Copilot lê as flags quando inicia, então reinicie depois (`/restart`).

### Passo 3c: OpenAI Codex CLI

O Codex não executa scripts personalizados, mas você pode ativar os itens nativos dele em `~/.codex/config.toml`. Esse arquivo é TOML, não JSON:

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Se o arquivo já tiver uma seção `[tui]`, coloque a linha `status_line` embaixo dela em vez de adicionar um segundo `[tui]`. Você também pode escolher os itens num menu com `/statusline` dentro do Codex.

### Passo 4: reinicie e confira

Reinicie a ferramenta. Se a linha de status não aparecer, dê uma olhada em [Solução de problemas](#solução-de-problemas).

### Confira seu settings.json

Rode isto antes de reiniciar. Se o arquivo for válido, ele é impresso de volta. Se não for, aparece a linha e a coluna do problema:

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

Depois confirme que o `statusLine` está no nível principal. Isto deve imprimir o seu comando. Se imprimir `null`, o bloco está aninhado dentro de outra coisa:

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## Opções

O Pulseline lê algumas variáveis de ambiente. No Claude Code, o lugar mais fácil para defini-las é o bloco `env` em `~/.claude/settings.json`, que também fica no nível principal, como o `statusLine`:

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

No Copilot CLI, defina no perfil do seu shell: `export PULSELINE_HIDE=cost` no `~/.zshrc` ou `~/.bashrc`, ou `setx PULSELINE_HIDE cost` no Windows.

| Variável | O que faz |
|---|---|
| `PULSELINE_HIDE` | Esconde os segmentos que você listar, separados por vírgula: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | Mostra rótulos de texto (`ctx`, `5h`, `cost`…) em vez de emojis, para terminais ou fontes que não conseguem exibi-los |
| `PULSELINE_HOME` | Diz ao instalador onde colocar o script (padrão `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | Diz ao instalador onde a sua ferramenta guarda as configurações, se você mudou o lugar |

## Como funciona o timer do cache

`💾 cache 47m of 1h` quer dizer que o cache de prompt da conversa expira em 47 minutos, de uma duração total de 1 hora. O número fica amarelo quando resta menos de 20% desse tempo. Depois que o cache expira, você vê `cold` em vermelho, junto com quantos tokens a sua próxima mensagem vai ter que gravar no cache de novo.

O Claude Code escolhe a duração do cache a cada requisição. Você tem 1 hora numa assinatura do Claude enquanto estiver dentro do uso do seu plano. Você tem 5 minutos no uso extra, com uma chave de API ou um provedor de nuvem, ou quando define `FORCE_PROMPT_CACHING_5M=1` ou `promptCacheTtl: "5m"`. Gravar no cache de 5 minutos custa 1,25× o preço de entrada e gravar no cache de 1 hora custa 2×; ler do cache custa 0,1× ou menos. Os detalhes estão em [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime).

O Pulseline usa os dados de `prompt_cache` que o Claude Code envia (versão 2.1.251 em diante). Em versões mais antigas, ele estima o timer a partir da transcrição da sessão. Este segmento só aparece no Claude Code.

## Solução de problemas

| Sintoma | Solução |
|---|---|
| Aviso `Invalid marketplace entry was ignored ... statusLine` | O `statusLine` está dentro de `extraKnownMarketplaces`. Mova para o nível principal ([veja o exemplo acima](#leia-isto-antes-de-editar)). |
| A ferramenta diz que o settings.json é inválido, ou ignora todas as suas configurações | Tem uma vírgula ou chave fora do lugar. [Confira o arquivo](#confira-seu-settingsjson) e ele mostra a linha. |
| A linha de status não aparece e não há erro | Rode o script você mesmo: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. Você deve ver duas linhas. Se aparecerem, o `statusLine` provavelmente está aninhado dentro de outro bloco, então confira se ele está no nível principal. |
| O Copilot CLI não mostra nada | Confirme que a feature flag `STATUS_LINE` está ativa (ou inicie o Copilot com `--experimental`) e reinicie. |
| `jq: command not found` | Instale o `jq` ou use a versão em Python. |
| No Windows, `python` abre a Microsoft Store | Instale o Python pelo [python.org](https://www.python.org/downloads/), marque *Add python.exe to PATH* e rode o instalador de novo. |
| Aparecem quadradinhos no lugar dos emojis | Defina `PULSELINE_NO_EMOJI=1` ou troque para uma fonte que tenha emojis. |
| Você quebrou o settings.json e quer o antigo de volta | Toda vez que o instalador roda, ele salva uma cópia `settings.json.bak-<date>` ao lado do arquivo. |

## Desinstalação

1. Remova o bloco `statusLine` de `~/.claude/settings.json` e/ou `~/.copilot/settings.json`. No Copilot, você também pode tirar `STATUS_LINE` de `feature_flags.enabled` se nada mais precisar dela.
2. No Codex, apague a linha `status_line` de `~/.codex/config.toml`.
3. Apague a pasta `~/.pulseline/` e reinicie suas ferramentas.

## Licença

[MIT](../LICENSE)
