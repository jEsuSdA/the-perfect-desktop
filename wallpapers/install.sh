#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
DEST="$HOME/Wallpapers"

echo "Installing wallpapers..."

mkdir -p "$DEST"

for ext in jpg png; do
    for f in "$SCRIPT_DIR"/*."$ext"; do
        [ -f "$f" ] || continue
        cp "$f" "$DEST/"
    done
done
echo "  ✔ Wallpapers copied to $DEST/"

echo "Done! Set them via Settings → Desktop."
