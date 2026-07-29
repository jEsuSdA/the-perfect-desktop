#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
DEST="$HOME/.themes"

echo "Installing XFWM4 window themes..."

mkdir -p "$DEST"

for ARCHIVE in "$SCRIPT_DIR"/*.7z; do
    [ -f "$ARCHIVE" ] || continue
    7za x "$ARCHIVE" -o"$DEST" -aoa >/dev/null 2>&1
    echo "  ✔ Extracted: $(basename "$ARCHIVE")"
done

echo "Done! Select themes in Settings → Window Manager."
