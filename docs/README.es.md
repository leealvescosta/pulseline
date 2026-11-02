# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · **Español** · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [한국어](README.ko.md)

Pulseline es una línea de estado colorida para herramientas de programación con IA en la terminal. Muestra el modelo, la carpeta y la rama de git, cuánto se ha llenado la ventana de contexto, cuánto has gastado de tus límites de uso, cuándo se enfría la caché de prompts, cuánto ha costado la sesión y cuántas líneas has cambiado. Se adapta al ancho de la terminal.

| Herramienta | Soporte |
|---|---|
| [Claude Code](https://claude.com/claude-code) | Soporte completo. Ejecuta el script de Pulseline. |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Ejecuta el script de Pulseline. Las líneas de estado personalizadas siguen siendo una función experimental de Copilot. |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex no puede ejecutar scripts personalizados, así que el instalador activa sus elementos integrados más parecidos. |

![Vista previa de Pulseline](../assets/pulseline-preview.png)
<sub>De arriba abajo: Claude Code en una terminal ancha, en una estrecha, con <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code>, y luego GitHub Copilot CLI y OpenAI Codex CLI. <a href="../assets/pulseline-preview.svg">Versión vectorial (SVG)</a>.</sub>

## Qué muestra

| Segmento | Qué muestra |
|---|---|
| 🤖 modelo · 📁 carpeta · 🌿 rama | El modelo actual, la carpeta de trabajo y la rama de git |
| 👾 `@agent` · `INSERT` | El subagente activo y el modo de vim (en Claude Code, cuando se usan) |
| 🧠 contexto | Cuánto de la ventana de contexto está en uso, como barra, porcentaje y tokens `used/total` |
| 🕔 5h · 📅 7d | Los límites de tu suscripción de Claude y cuánto falta para que se reinicie cada uno |
| 💾 caché | Cuánto falta para que la caché de prompts se enfríe, o `cold · 73k to rewrite` una vez que se ha enfriado |
| 💰 coste | Cuánto ha costado la sesión en USD y cuánto tiempo lleva en marcha |
| 🎫 premium | Solicitudes premium usadas en la sesión (Copilot CLI) |
| 📝 +/- | Líneas añadidas y eliminadas en esta sesión |

Los números se ven en verde por debajo del 70%, en amarillo del 70 al 89% y en rojo a partir del 90%.

Cuando la ventana se estrecha, los segmentos pasan a una nueva línea. Si dos líneas siguen sin bastar, Pulseline oculta primero las barras y después las horas de reinicio.

Si una herramienta no informa de algún dato (los límites de uso cuando usas una clave de API, por ejemplo), ese segmento simplemente no aparece.

Hay dos versiones que imprimen exactamente lo mismo: `pulseline.py` solo necesita Python 3, y `pulseline.sh` necesita bash y jq.

## Instalación rápida

El instalador busca Claude Code, Copilot CLI y Codex CLI y te dice cuáles ha encontrado. Pone el script en `~/.pulseline/` (en Windows, `C:\Users\<you>\.pulseline\`) y luego añade la configuración de la línea de estado a cada herramienta, sin tocar el resto de tu configuración.

Antes de cambiar un archivo, guarda una copia a su lado (`settings.json.bak-<date>`). Si un archivo no es JSON válido, no lo toca. Puedes volver a ejecutarlo cuando quieras; actualiza la misma configuración en lugar de añadirla dos veces.

### Windows

Lo más fácil: descarga el proyecto ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)), descomprímelo y haz doble clic en `install-windows.cmd`.

También puedes pegar esto en PowerShell:

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Si no tienes Python 3, el instalador se ofrece a instalarlo con `winget`.

### macOS

Lo más fácil: descarga el ZIP, descomprímelo y haz doble clic en `install-macos.command`. Puede que macOS lo bloquee la primera vez. Si pasa, haz clic derecho en el archivo, elige **Open** y luego **Open** otra vez.

También puedes pegar esto en Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

Cuando termine, reinicia Claude Code, Copilot CLI o Codex. La línea de estado aparece en la parte de abajo de la terminal.

## Instalación manual

### Lee esto antes de editar

Todos estos archivos de configuración son JSON, y un pequeño error puede romper el archivo entero o hacer que la herramienta ignore tu línea de estado sin decir nada. Cuatro cosas que conviene tener en cuenta:

1. Seguramente tu `settings.json` ya tiene otros ajustes. Añade el bloque `statusLine` junto a ellos en lugar de pegar encima del archivo.
2. `statusLine` tiene que estar en el nivel superior, directamente dentro de las `{ }` más externas. Si acaba dentro de otro bloque como `env`, `permissions` o `extraKnownMarketplaces`, no funcionará.
3. Pon una coma entre elementos, pero no después del último.
4. Revisa el archivo antes de reiniciar (mira [Revisa tu settings.json](#revisa-tu-settingsjson)).

Este es un error habitual. El bloque `statusLine` acabó dentro de `extraKnownMarketplaces`:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } },
    "statusLine": {                       // ✗ dentro de otro bloque
      "type": "command",
      "command": "python3 ~/.pulseline/pulseline.py"
    }
  }
}
```

Entonces Claude Code cree que `statusLine` es un marketplace de plugins, lo ignora y muestra este aviso:

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

Para arreglarlo, cierra primero el otro bloque y añade `statusLine` después, al mismo nivel:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← cierra extraKnownMarketplaces, y luego una coma
  "statusLine": {                         // ✓ nivel superior
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

Los comentarios `//` solo están para explicar. JSON no admite comentarios, así que no los pongas en tu archivo.

### Paso 1: copia el script

Crea la carpeta `~/.pulseline/` (en Windows, `C:\Users\<you>\.pulseline\`) y copia `pulseline.py` dentro. Si no tienes Python 3 pero sí `bash` y `jq`, usa `pulseline.sh`.

### Paso 2: elige tu comando

| Sistema | Valor de `command` |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

Algunos consejos para Windows:

- Usa barras normales (`C:/Users/...`). Las barras invertidas hay que duplicarlas en JSON (`C:\\Users\\...`), y es fácil olvidarse.
- Escribe la ruta completa en lugar de `~`, porque `~` no se expande en todas partes.
- Si la ruta tiene espacios, ponle comillas dentro de la cadena: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### Paso 3a: Claude Code

Abre `~/.claude/settings.json` (en Windows, `C:\Users\<you>\.claude\settings.json`). Si no existe, créalo con `{}` dentro. Luego añade:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### Paso 3b: GitHub Copilot CLI

Abre `~/.copilot/settings.json` (o la carpeta indicada en `COPILOT_HOME`). La línea de estado personalizada de Copilot sigue siendo experimental, así que también tienes que activar la feature flag `STATUS_LINE`:

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

Si ya tienes una lista `feature_flags.enabled`, añade `"STATUS_LINE"` a ella en lugar de crear otra. También sirve iniciar Copilot con `copilot --experimental` o ejecutar `/experimental` dentro. Copilot lee las flags al arrancar, así que reinícialo después (`/restart`).

### Paso 3c: OpenAI Codex CLI

Codex no ejecuta scripts personalizados, pero puedes activar sus elementos integrados en `~/.codex/config.toml`. Este archivo es TOML, no JSON:

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Si el archivo ya tiene una sección `[tui]`, pon la línea `status_line` debajo en lugar de añadir un segundo `[tui]`. También puedes elegir los elementos desde un menú con `/statusline` dentro de Codex.

### Paso 4: reinicia y comprueba

Reinicia la herramienta. Si la línea de estado no aparece, echa un vistazo a [Solución de problemas](#solución-de-problemas).

### Revisa tu settings.json

Ejecuta esto antes de reiniciar. Si el archivo es válido, lo vuelve a imprimir. Si no, te dice la línea y la columna del problema:

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

Después comprueba que `statusLine` está en el nivel superior. Esto debería imprimir tu comando. Si imprime `null`, el bloque está anidado dentro de otra cosa:

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## Opciones

Pulseline lee algunas variables de entorno. En Claude Code, el sitio más fácil para definirlas es el bloque `env` de `~/.claude/settings.json`, que también va en el nivel superior, como `statusLine`:

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

En Copilot CLI, defínelas en el perfil de tu shell: `export PULSELINE_HIDE=cost` en `~/.zshrc` o `~/.bashrc`, o `setx PULSELINE_HIDE cost` en Windows.

| Variable | Qué hace |
|---|---|
| `PULSELINE_HIDE` | Oculta los segmentos que indiques, separados por comas: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | Muestra etiquetas de texto (`ctx`, `5h`, `cost`…) en lugar de emojis, para terminales o fuentes que no pueden mostrarlos |
| `PULSELINE_HOME` | Le dice al instalador dónde poner el script (por defecto `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | Le dice al instalador dónde guarda tu herramienta su configuración, si la has movido |

## Cómo funciona el temporizador de la caché

`💾 cache 47m of 1h` significa que la caché de prompts de la conversación caduca en 47 minutos, de una duración total de 1 hora. El número se pone amarillo cuando queda menos del 20% de ese tiempo. Cuando la caché caduca, verás `cold` en rojo, junto con cuántos tokens tendrá que volver a escribir en la caché tu siguiente mensaje.

Claude Code elige la duración de la caché en cada solicitud. Tienes 1 hora con una suscripción de Claude mientras estés dentro del uso de tu plan. Tienes 5 minutos con uso adicional, con una clave de API o un proveedor en la nube, o cuando defines `FORCE_PROMPT_CACHING_5M=1` o `promptCacheTtl: "5m"`. Escribir en la caché de 5 minutos cuesta 1,25× el precio de entrada y escribir en la de 1 hora cuesta 2×; leer de la caché cuesta 0,1× o menos. Tienes los detalles en [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime).

Pulseline usa los datos de `prompt_cache` que envía Claude Code (versión 2.1.251 y posteriores). En versiones anteriores estima el temporizador a partir de la transcripción de la sesión. Este segmento solo aparece en Claude Code.

## Solución de problemas

| Síntoma | Solución |
|---|---|
| Aviso `Invalid marketplace entry was ignored ... statusLine` | `statusLine` está dentro de `extraKnownMarketplaces`. Muévelo al nivel superior ([mira el ejemplo de arriba](#lee-esto-antes-de-editar)). |
| La herramienta dice que settings.json no es válido, o ignora toda tu configuración | Hay una coma o una llave mal puesta. [Revisa el archivo](#revisa-tu-settingsjson) y te mostrará la línea. |
| La línea de estado no aparece y no hay ningún error | Ejecuta el script tú mismo: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. Deberías ver dos líneas. Si las ves, seguramente `statusLine` está anidado dentro de otro bloque, así que comprueba que esté en el nivel superior. |
| Copilot CLI no muestra nada | Asegúrate de que la feature flag `STATUS_LINE` está activada (o inicia Copilot con `--experimental`) y reinícialo. |
| `jq: command not found` | Instala `jq` o usa la versión de Python. |
| En Windows, `python` abre Microsoft Store | Instala Python desde [python.org](https://www.python.org/downloads/), marca *Add python.exe to PATH* y vuelve a ejecutar el instalador. |
| Ves cuadrados en lugar de emojis | Define `PULSELINE_NO_EMOJI=1` o cambia a una fuente que tenga emojis. |
| Has roto settings.json y quieres recuperar el anterior | Cada vez que se ejecuta el instalador, guarda una copia `settings.json.bak-<date>` junto al archivo. |

## Desinstalación

1. Quita el bloque `statusLine` de `~/.claude/settings.json` y/o `~/.copilot/settings.json`. En Copilot también puedes quitar `STATUS_LINE` de `feature_flags.enabled` si nada más lo necesita.
2. En Codex, borra la línea `status_line` de `~/.codex/config.toml`.
3. Borra la carpeta `~/.pulseline/` y reinicia tus herramientas.

## Licencia

[MIT](../LICENSE)
