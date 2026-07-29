#!/bin/bash
#
# install-all.sh — Instala todos los componentes del proyecto
#
# Por defecto pregunta interactivamente por cada componente.
# Con --all ejecuta todo sin preguntar.
# Con --local <path> usa un clon local en vez de descargar de GitHub.
#
# jEsuSdA 8)

set -e

REPO_URL="https://github.com/jEsuSdA/the-perfect-desktop.git"
INTERACTIVE=true
LOCAL_PATH=""

usage() {
    cat <<EOF
Usage: $0 [--all] [--local <path>]

  --all          Instalar todo sin preguntar
  --local <path> Usar repositorio local (no descargar)
  -h, --help     Mostrar esta ayuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)     INTERACTIVE=false;     shift ;;
        --local)   LOCAL_PATH="$2";       shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *)         echo "Opción desconocida: $1"; usage; exit 1 ;;
    esac
done

# ── Obtener repositorio ──
if [ -n "$LOCAL_PATH" ]; then
    [ -d "$LOCAL_PATH" ] || { echo "Error: no existe: $LOCAL_PATH"; exit 1; }
    REPO_DIR="$LOCAL_PATH"
else
    command -v git >/dev/null 2>&1 || { echo "Error: git not found"; exit 1; }
    REPO_DIR="/tmp/the-perfect-desktop-$$"
    echo "Descargando repositorio..."
    git clone --depth=1 "$REPO_URL" "$REPO_DIR"
    echo ""
fi

cd "$REPO_DIR"

if [ -z "$LOCAL_PATH" ]; then
    trap 'rm -rf "$REPO_DIR"' EXIT HUP INT TERM
fi

# ── Ejecutar un instalador ──
run_installer() {
    local desc="$1"
    local script="$2"
    shift 2

    [ -f "$script" ] || { echo "  ⚠ No encontrado: $script"; return 0; }

    echo ""
    echo "========================================"
    echo " $desc"
    echo "========================================"

    if $INTERACTIVE; then
        read -r -p "¿Instalar $desc? [S/n] " reply
        case "$reply" in
            n|N|no|No) echo "  ⏭ Omitido"; return 0 ;;
        esac
    fi

    echo "  Ejecutando: $script $*"
    (cd "$(dirname "$script")" && "./$(basename "$script")" "$@")
    local ec=$?
    if [ $ec -eq 0 ]; then
        echo "  ✔ $desc — OK"
    else
        echo "  ✗ $desc — FALLÓ (código $ec)"
    fi
    return $ec
}

# ── Componentes ──
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  The Perfect Desktop — Instalador    ║"
echo "╚══════════════════════════════════════╝"

run_installer "Bashrc files"                    "bashrc/install.sh"
run_installer "Breeze cursor theme"             "cursors/install.sh"
run_installer "Thunar custom actions"           "extra/install.sh"

if command -v 7za >/dev/null 2>&1; then
    run_installer "Font configuration"          "fonts/install.sh"
else
    echo ""
    echo "========================================"
    echo " Font configuration"
    echo "========================================"
    echo "  ⚠ 7za no instalado — instala p7zip-full y ejecuta:"
    echo "     cd fonts && ./install.sh"
fi

run_installer "Kitty terminal config"           "kitty-terminal/install.sh"
run_installer "Wallpapers"                      "wallpapers/install.sh"
run_installer "XFCE terminal backgrounds"       "xfce-terminal/install.sh"
run_installer "XFWM4 window themes"             "xfwm4-themes/install.sh"

GREYBIRD_7Z=
for f in greybird-patched/Greybird-*.7z; do
    [ -f "$f" ] || continue
    GREYBIRD_7Z="$f"
done
if [ -n "$GREYBIRD_7Z" ]; then
    run_installer "Greybird-patched GTK theme"  "greybird-patched/install-greybird.sh" "$GREYBIRD_7Z"
fi

if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
    run_installer "Papirus-patched icon theme"  "papirus-patched/install-papirus.sh" "--download"
else
    echo ""
    echo "========================================"
    echo " Papirus-patched icon theme"
    echo "========================================"
    echo "  ⚠ curl/wget no instalado — instala uno y ejecuta:"
    echo "     cd papirus-patched && sudo ./install-papirus.sh --download"
fi

# ── Papirus app-specific patches ──
echo ""
echo "--- Papirus app-specific patches ---"

run_installer "  Papirus aMule icons"            "papirus-patched/papirus-amule/install.sh"
run_installer "  Papirus Claws Mail theme"      "papirus-patched/papirus-claws-mail/install.sh"
run_installer "  Papirus FBreader icons"         "papirus-patched/papirus-fbreader/install.sh"
run_installer "  Papirus gFTP icons"             "papirus-patched/papirus-gftp/install.sh"
run_installer "  Papirus LibreOffice Sifr"       "papirus-patched/papirus-libreoffice/install-papirus-lo.sh"
run_installer "  Papirus MComix icons"           "papirus-patched/papirus-mcomix/install.sh"
run_installer "  Papirus Remarkable icons"       "papirus-patched/papirus-remarkable/install.sh"
run_installer "  Papirus Thunderbird tray"       "papirus-patched/papirus-thunderbird-tray/install.sh"
run_installer "  Papirus Zim wiki icons"         "papirus-patched/papirus-zim/install.sh"
run_installer "  XFCE4 Weather icons"            "papirus-patched/xfce4-weather/install.sh"

run_installer "Pasodoble sound theme"           "sound-theme/install.sh"
run_installer "Compositors (picom/compton/fastcompmgr)" "compositors/install.sh"

echo ""
echo "========================================"
echo " ¡Todo listo!"
echo "========================================"
