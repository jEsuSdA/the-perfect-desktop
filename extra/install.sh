#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
DEST="$HOME/.config/Thunar"
SOURCE="$SCRIPT_DIR/thunar.uca.xml"

echo "Installing Thunar custom actions..."

mkdir -p "$DEST"

if [ -f "$DEST/thunar.uca.xml" ]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    cp "$DEST/thunar.uca.xml" "$DEST/thunar.uca.xml.bak.$TIMESTAMP"
    echo "  ✔ Backup: $DEST/thunar.uca.xml.bak.$TIMESTAMP"
fi

cp "$SOURCE" "$DEST/thunar.uca.xml"
echo "  ✔ thunar.uca.xml → $DEST/"

echo "Done! Restart Thunar or press Ctrl+Alt+T to reload."
