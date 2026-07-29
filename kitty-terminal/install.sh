#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
DEST="$HOME/.config/kitty"

echo "Installing kitty terminal config..."

mkdir -p "$DEST"

if [ -f "$DEST/kitty.conf" ]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    cp "$DEST/kitty.conf" "$DEST/kitty.conf.bak.$TIMESTAMP"
    echo "  ✔ Backup: $DEST/kitty.conf.bak.$TIMESTAMP"
fi

cp "$SCRIPT_DIR/kitty.conf" "$DEST/kitty.conf"
echo "  ✔ kitty.conf → $DEST/"

for f in "$SCRIPT_DIR"/*.png; do
    [ -f "$f" ] || continue
    cp "$f" "$DEST/"
    echo "  ✔ $(basename "$f") → $DEST/"
done

echo "Done! Restart kitty to apply."
