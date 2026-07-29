#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
CONF_DEST="$HOME/.config/fontconfig"
FONT_DEST="$HOME/.fonts"

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

echo "Done!"
