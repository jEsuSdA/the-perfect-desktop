#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
CONF_DEST="$HOME/.config/fontconfig"
FONT_DEST="$HOME/.fonts"

# XFCE rendering settings (see README.md). Adjust XFCE_DPI to your screen.
XFCE_DPI=120
XFCE_UI_FONT="Droid Sans 7.5"
XFCE_MONO_FONT="Adwaita Mono 7.5"

echo "Installing font configuration..."

mkdir -p "$CONF_DEST"

if [ -f "$CONF_DEST/fonts.conf" ]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    cp "$CONF_DEST/fonts.conf" "$CONF_DEST/fonts.conf.bak.$TIMESTAMP"
    echo "  ✔ Backup: $CONF_DEST/fonts.conf.bak.$TIMESTAMP"
fi

cp "$SCRIPT_DIR/fonts.conf" "$CONF_DEST/fonts.conf"
echo "  ✔ fonts.conf → $CONF_DEST/"

echo "Installing font archives..."
mkdir -p "$FONT_DEST"

for ARCHIVE in "$SCRIPT_DIR"/fonts-*.7z; do
    [ -f "$ARCHIVE" ] || continue
    7za x "$ARCHIVE" -o"$FONT_DEST" -aoa >/dev/null 2>&1
    echo "  ✔ Extracted: $(basename "$ARCHIVE")"
done

echo "Updating font cache..."
fc-cache -fv 2>/dev/null && echo "  ✔ Font cache updated" || echo "  ⚠ fc-cache failed (non-fatal)"

if [ "$SKIP_XFCONF" = "1" ]; then
    echo "Skipping XFCE settings (SKIP_XFCONF=1)..."
elif [ "$(id -u)" = "0" ]; then
    echo "  ⚠ XFCE settings skipped (running as root; they are per-user)"
elif ! command -v xfconf-query >/dev/null 2>&1; then
    echo "  ⚠ XFCE settings skipped (xfconf-query not found)"
elif ! xfconf-query -c xsettings -l >/dev/null 2>&1; then
    echo "  ⚠ XFCE settings skipped (xfconfd not reachable)"
else
    set_xfconf() {
        PROP=$1
        VALUE=$2
        TYPE=$3
        if xfconf-query -c xsettings -p "$PROP" >/dev/null 2>&1; then
            xfconf-query -c xsettings -p "$PROP" -s "$VALUE" >/dev/null
        else
            xfconf-query -c xsettings -p "$PROP" -n -t "$TYPE" -s "$VALUE" >/dev/null
        fi
    }
    set_xfconf /Xft/Antialias 1 int
    set_xfconf /Xft/Hinting 1 int
    set_xfconf /Xft/HintStyle hintslight string
    set_xfconf /Xft/RGBA none string
    set_xfconf /Xft/DPI "$XFCE_DPI" int
    set_xfconf /Gtk/FontName "$XFCE_UI_FONT" string
    set_xfconf /Gtk/MonospaceFontName "$XFCE_MONO_FONT" string
    echo "  ✔ XFCE settings applied (DPI $XFCE_DPI, hinting slight, grayscale AA, fonts)"
fi

if [ "$SKIP_QT" = "1" ]; then
    echo "Skipping Qt settings (SKIP_QT=1)..."
else
    QT_MISSING=""
    command -v qt5ct >/dev/null 2>&1 || QT_MISSING="$QT_MISSING qt5ct"
    command -v qt6ct >/dev/null 2>&1 || QT_MISSING="$QT_MISSING qt6ct"

    if [ -n "$QT_MISSING" ]; then
        if [ "$(id -u)" = "0" ]; then
            apt-get install -y $QT_MISSING && echo "  ✔ Qt packages installed:$QT_MISSING" || echo "  ⚠ apt-get failed for:$QT_MISSING"
        elif command -v sudo >/dev/null 2>&1; then
            sudo apt-get install -y $QT_MISSING && echo "  ✔ Qt packages installed:$QT_MISSING" || echo "  ⚠ apt-get failed for:$QT_MISSING"
        else
            echo "  ⚠ Missing Qt packages:$QT_MISSING (needed for Qt font sync)"
            echo "      run: sudo apt-get install$QT_MISSING"
        fi
    else
        echo "  ✔ Qt packages present (qt5ct, qt6ct)"
    fi

    for QTCFG in qt5ct qt6ct; do
        QTDST="$HOME/.config/$QTCFG/$QTCFG.conf"
        if [ -f "$QTDST" ]; then
            echo "  ✔ Existing $QTDST kept"
        elif [ -f "$SCRIPT_DIR/$QTCFG.conf" ]; then
            mkdir -p "$HOME/.config/$QTCFG"
            cp "$SCRIPT_DIR/$QTCFG.conf" "$QTDST"
            echo "  ✔ $QTCFG.conf → $HOME/.config/$QTCFG/"
        fi
    done

    QT_ENV_LINE="export QT_QPA_PLATFORMTHEME=qt5ct"
    for ENVFILE in "$HOME/.xsessionrc" "$HOME/.profile"; do
        if [ -f "$ENVFILE" ] && grep -qF "$QT_ENV_LINE" "$ENVFILE"; then
            echo "  ✔ $(basename "$ENVFILE"): already configured"
        else
            printf '\n%s\n' "$QT_ENV_LINE" >> "$ENVFILE"
            echo "  ✔ $(basename "$ENVFILE"): QT_QPA_PLATFORMTHEME=qt5ct added"
        fi
    done

    XRESFILE="$HOME/.Xresources"
    if [ -f "$XRESFILE" ] && grep -q "^Xft.dpi:" "$XRESFILE"; then
        echo "  ✔ .Xresources: Xft settings already present"
    else
        {
            printf '\n'
            printf 'Xft.dpi: %s\n' "$XFCE_DPI"
            printf 'Xft.antialias: 1\n'
            printf 'Xft.hinting: 1\n'
            printf 'Xft.hintstyle: hintslight\n'
            printf 'Xft.rgba: none\n'
        } >> "$XRESFILE"
        echo "  ✔ .Xresources: Xft settings added"
    fi
    if command -v xrdb >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
        xrdb -merge "$XRESFILE" 2>/dev/null && echo "  ✔ X resources merged into current display"
    fi

    echo "  ℹ Log out and back in to apply Qt environment changes"
fi

echo "Done!"
