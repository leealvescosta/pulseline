# Pulseline

[English](../README.md) · [Português](README.pt-BR.md) · **Español** · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [한국어](README.ko.md)

Una línea de estado colorida y que se adapta al ancho de la terminal para CLIs de programación con IA: modelo, carpeta, rama de git, ventana de contexto, límites de uso, temporizador de la caché de prompts, coste de la sesión y líneas modificadas.

| Herramienta | Soporte |
|---|---|
| [Claude Code](https://claude.com/claude-code) | Completo: ejecuta el script de Pulseline |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | Ejecuta el script de Pulseline (la línea de estado personalizada es una función experimental de Copilot) |
| [OpenAI Codex CLI](https://github.com/openai/codex) | Codex no puede ejecutar scripts personalizados, así que el instalador activa sus elementos integrados más parecidos |

![Vista previa de Pulseline](../assets/pulseline-preview.png)
<sub>De arriba abajo: Claude Code en una terminal ancha, en una estrecha, con <code>PULSELINE_NO_EMOJI</code> + <code>PULSELINE_HIDE</code>, y luego GitHub Copilot CLI y OpenAI Codex CLI. <a href="../assets/pulseline-preview.svg">Versión vectorial (SVG)</a>.</sub>

## Características

| Segmento | Qué muestra |
|---|---|
| 🤖 model · 📁 folder · 🌿 branch | Modelo actual, carpeta de trabajo y rama de git |
| 👾 `@agent` · `INSERT` | Subagente activo y modo vim (Claude Code, solo cuando existen) |
| 🧠 context | Uso de la ventana de contexto, como barra, porcentaje y tokens `used/total` |
| 🕔 5h · 📅 7d | Límites de uso de la suscripción de Claude y el tiempo que falta para que cada uno se restablezca |
| 💾 cache | Tiempo hasta que la caché de prompts se enfría, o `cold · 73k to rewrite` |
| 💰 cost | Coste de la sesión en USD y tiempo total de la sesión |
| 🎫 premium | Solicitudes premium usadas en la sesión (Copilot CLI) |
| 📝 +/- | Líneas añadidas y eliminadas en esta sesión |

- **Colores:** verde por debajo del 70 %, amarillo del 70 al 89 %, rojo a partir del 90 %.
- **Se ajusta a cualquier ancho:** los segmentos pasan a una nueva línea a medida que la ventana se estrecha. Si aun así no caben en dos líneas, se ocultan primero las barras y después las horas de restablecimiento.
- **Solo lo que está disponible:** un segmento que la herramienta no informa (por ejemplo, los límites de uso con una clave de API) simplemente se omite.
- **Dos versiones equivalentes:** `pulseline.py` (Python 3, sin paquetes) y `pulseline.sh` (bash + jq). Las dos imprimen lo mismo.

## Instalación rápida (un clic)

El instalador:

1. **Detecta** cuáles de estas herramientas tienes (Claude Code, Copilot CLI y Codex CLI) y te dice lo que encontró.
2. Instala el script una sola vez en `~/.pulseline/` (Windows: `C:\Users\<you>\.pulseline\`).
3. Añade **solo** las claves de la línea de estado a la configuración de cada herramienta y conserva todo lo demás. Antes de cualquier cambio se guarda una copia de seguridad (`settings.json.bak-<date>`), y un archivo que no sea JSON válido no se toca.

Volver a ejecutarlo es seguro: actualiza las mismas claves en lugar de crear duplicados.

### Windows

**Lo más fácil:** descarga el repositorio ([Code → Download ZIP](https://github.com/leealvescosta/pulseline/archive/refs/heads/main.zip)), descomprímelo y haz doble clic en **`install-windows.cmd`**.

O pega esto en PowerShell:

```powershell
irm https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.ps1 | iex
```

Si falta Python 3, el instalador ofrece instalarlo con `winget`.

### macOS

**Lo más fácil:** descarga el ZIP, descomprímelo y haz doble clic en **`install-macos.command`**. La primera vez, macOS puede bloquearlo: haz clic derecho en el archivo → **Open** → **Open**.

O pega esto en Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/leealvescosta/pulseline/main/install.sh | bash
```

Después, **reinicia tu herramienta** (Claude Code, Copilot CLI o Codex). La línea de estado aparece en la parte inferior de la terminal.

## Instalación manual

### Antes de editar: las reglas que evitan la mayoría de los errores

Todos los archivos de configuración de esta sección son JSON. Estos son los errores que los rompen (o que hacen que la herramienta ignore tu línea de estado sin avisar):

1. **Combina, no reemplaces.** Tu `settings.json` probablemente ya tiene otras opciones. Añade el bloque `statusLine` junto a ellas; no pegues encima de todo el archivo.
2. **`statusLine` va en el nivel superior**, como hijo directo de las `{ }` más externas. **No** debe ir dentro de otro bloque como `env`, `permissions` o `extraKnownMarketplaces`.
3. **Las comas van entre elementos, nunca después del último.**
4. **Revisa el archivo antes de reiniciar** (consulta [Valida tu settings.json](#valida-tu-settingsjson)).

**Mal** — `statusLine` terminó dentro de `extraKnownMarketplaces`:

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

Claude Code entonces interpreta `statusLine` como un marketplace de plugins, lo ignora y muestra esta advertencia:

```
Invalid marketplace entry was ignored: source: Invalid input: expected object, received undefined
```

**Bien** — cierra primero el otro bloque y luego añade `statusLine` como su hermano:

```jsonc
{
  "extraKnownMarketplaces": {
    "my-plugins": { "source": { "source": "github", "repo": "me/plugins" } }
  },                                      // ← cierra extraKnownMarketplaces y luego una coma
  "statusLine": {                         // ✓ nivel superior
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

(Los comentarios `//` solo están para explicar; JSON no los admite, así que no los copies).

### Paso 1: copia el script

Crea la carpeta `~/.pulseline/` (Windows: `C:\Users\<you>\.pulseline\`) y copia `pulseline.py` en ella. Usa `pulseline.sh` en su lugar si no tienes Python 3 pero sí `bash` y `jq`.

### Paso 2: elige tu comando

| Sistema | Valor de `command` |
|---|---|
| macOS / Linux, Python | `python3 ~/.pulseline/pulseline.py` |
| macOS / Linux, bash | `bash ~/.pulseline/pulseline.sh` |
| Windows, Python | `python C:/Users/<you>/.pulseline/pulseline.py` |

En Windows:

- Usa **barras normales** (`C:/Users/...`). Las barras invertidas en JSON deben duplicarse (`C:\\Users\\...`), y olvidarlo es un error frecuente.
- Usa la **ruta completa** en lugar de `~`, que no se expande en todas partes.
- Si la ruta tiene espacios, ponla entre comillas dentro de la cadena: `"\"C:/Program Files/Python312/python.exe\" C:/Users/<you>/.pulseline/pulseline.py"`.

### Paso 3a: Claude Code

Archivo: `~/.claude/settings.json` (Windows: `C:\Users\<you>\.claude\settings.json`). Si no existe, créalo con `{}`. Añade:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.pulseline/pulseline.py"
  }
}
```

### Paso 3b: GitHub Copilot CLI

Archivo: `~/.copilot/settings.json` (o la carpeta indicada en `COPILOT_HOME`). La línea de estado personalizada de Copilot es experimental, así que también necesita la feature flag `STATUS_LINE`:

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

Si `feature_flags.enabled` ya existe, añade `"STATUS_LINE"` a esa lista en lugar de crear otra. También puedes iniciar Copilot con `copilot --experimental` o ejecutar `/experimental` dentro de él. Después reinicia Copilot (`/restart`): las flags se leen al arrancar.

### Paso 3c: OpenAI Codex CLI

Codex no ejecuta scripts personalizados. Añade sus elementos integrados a `~/.codex/config.toml` (TOML, no JSON):

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Si el archivo ya tiene una sección `[tui]`, pon la línea `status_line` debajo de ella; no crees una segunda `[tui]`. También puedes elegir los elementos de forma interactiva con `/statusline` dentro de Codex.

### Paso 4: reinicia y comprueba

Reinicia la herramienta. Si la línea de estado no aparece, consulta [Solución de problemas](#solución-de-problemas).

### Valida tu settings.json

Ejecuta esto antes de reiniciar. Si el archivo es válido, lo vuelve a imprimir; si no, muestra la línea y la columna del error:

```bash
python3 -m json.tool ~/.claude/settings.json            # macOS / Linux
```

```powershell
python -m json.tool $env:USERPROFILE\.claude\settings.json   # Windows
```

Luego comprueba que `statusLine` esté en el nivel superior. Esto debe imprimir tu comando; si imprime `null`, el bloque está anidado en otro sitio:

```bash
python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('statusLine'))"
```

## Opciones

Defínelas como variables de entorno. En Claude Code, el lugar más sencillo es el bloque `env` de `~/.claude/settings.json` (un bloque de nivel superior, como `statusLine`):

```json
{
  "env": {
    "PULSELINE_HIDE": "cost,7d",
    "PULSELINE_NO_EMOJI": "1"
  }
}
```

En Copilot CLI, defínelas en el perfil de tu shell (`export PULSELINE_HIDE=cost` en `~/.zshrc` / `~/.bashrc`, o `setx PULSELINE_HIDE cost` en Windows).

| Variable | Efecto |
|---|---|
| `PULSELINE_HIDE` | Segmentos que ocultar, separados por comas: `branch`, `agent`, `vim`, `ctx`, `5h`, `7d`, `cache`, `cost`, `premium`, `diff` |
| `PULSELINE_NO_EMOJI=1` | Etiquetas de texto en lugar de emojis (`ctx`, `5h`, `cost`…), para terminales o fuentes que no pueden mostrar emojis |
| `PULSELINE_HOME` | Instalador: dónde colocar el script (por defecto `~/.pulseline`) |
| `CLAUDE_CONFIG_DIR` / `COPILOT_HOME` / `CODEX_HOME` | Instalador: la carpeta de configuración de tu herramienta, si no está en la ubicación por defecto |

## Sobre el indicador de caché

`💾 cache 47m of 1h` es el tiempo que queda antes de que caduque la caché de prompts de la conversación, junto con el TTL en uso. Se vuelve amarillo cuando queda menos del 20 % del TTL y muestra `cold` en rojo cuando caduca, con cuántos tokens volverá a escribir en la caché el siguiente mensaje.

Claude Code elige el TTL en cada solicitud: **1 hora** con una suscripción de Claude dentro del uso del plan, y **5 minutos** con uso adicional, una clave de API o un proveedor en la nube, o cuando se define `FORCE_PROMPT_CACHING_5M=1` / `promptCacheTtl: "5m"`. Escribir en la caché de 5 minutos cuesta 1,25× el precio de entrada y en la de 1 hora, 2×; las lecturas de caché cuestan 0,1× o menos. Consulta [How Claude Code uses prompt caching](https://code.claude.com/docs/en/prompt-caching#cache-lifetime).

El script lee los datos `prompt_cache` del propio Claude Code (v2.1.251+); en versiones anteriores, hace una estimación a partir de la transcripción de la sesión. Este segmento es exclusivo de Claude Code.

## Solución de problemas

| Síntoma | Solución |
|---|---|
| Advertencia `Invalid marketplace entry was ignored ... statusLine` | `statusLine` está anidado dentro de `extraKnownMarketplaces`. Muévelo al nivel superior ([ver arriba](#antes-de-editar-las-reglas-que-evitan-la-mayoría-de-los-errores)). |
| La herramienta dice que settings.json no es válido, o ignora toda tu configuración | Hay una coma o una llave mal puesta. [Valida el archivo](#valida-tu-settingsjson); el error indica la línea. |
| La línea de estado no aparece y no hay ningún error | Ejecuta el script a mano: `echo '{}' \| python3 ~/.pulseline/pulseline.py`. Debería imprimir dos líneas. Si lo hace, probablemente `statusLine` está anidado: comprueba que esté en el nivel superior. |
| Copilot CLI no muestra nada | Comprueba la feature flag `STATUS_LINE` (o inicia con `--experimental`) y reinicia Copilot. |
| `jq: command not found` | Instala `jq` o cambia a la versión de Python. |
| Windows: `python` abre la Microsoft Store | Instala Python desde [python.org](https://www.python.org/downloads/) (marca *Add python.exe to PATH*) y vuelve a ejecutar el instalador. |
| Cuadrados en lugar de emojis | Define `PULSELINE_NO_EMOJI=1` o usa una fuente compatible con emojis. |
| Rompiste settings.json y quieres recuperarlo | Cada ejecución del instalador guarda un `settings.json.bak-<date>` junto a él. |

## Desinstalación

1. Elimina el bloque `statusLine` de `~/.claude/settings.json` y/o de `~/.copilot/settings.json` (y `STATUS_LINE` de `feature_flags.enabled` de Copilot si no lo usas para nada más).
2. En Codex, elimina la línea `status_line` de `~/.codex/config.toml`.
3. Borra la carpeta `~/.pulseline/` y reinicia tus herramientas.

## Licencia

[MIT](../LICENSE)
