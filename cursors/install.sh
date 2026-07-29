#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
DEST="$HOME/.icons"
ARCHIVE="$SCRIPT_DIR/breeze_cursors.7z"

if ! command -v 7za >/dev/null 2>&1; then
    echo "Error: 7za not found. Install p7zip (apt install p7zip-full) and try again."
    exit 1
fi

echo "Installing Breeze cursor theme..."

mkdir -p "$DEST"
7za x "$ARCHIVE" -o"$DEST" -aoa >/dev/null 2>&1
echo "  ✔ Extracted to $DEST"

echo "Done! Select Breeze in Settings → Mouse and Touchpad."
