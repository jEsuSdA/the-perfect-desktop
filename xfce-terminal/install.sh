#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
DEST="$HOME/.local/share/xfce4/backgrounds"

echo "Installing XFCE terminal backgrounds..."

mkdir -p "$DEST"

for f in "$SCRIPT_DIR"/*.png; do
    [ -f "$f" ] || continue
    cp "$f" "$DEST/"
    echo "  ✔ $(basename "$f") → $DEST/"
done

echo "Done! Select them in Settings → Appearance → Background."
