#!/bin/sh
set -e

FILE=$1

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Usage: $0 <greybird-theme-file.7z>"
    echo "Example: $0 Greybird-20260728.7z"
    exit 1
fi

DATE=$(date +%Y%m%d)
OUTPUT="Greybird-$DATE"
trap 'rm -rf "$OUTPUT"' EXIT HUP INT TERM

echo
echo "Extracting Greybird..."
echo "--------------------------------------------------"
7za x "$FILE" -o"$OUTPUT"

# Find the actual theme directory inside the extracted archive
THEME_DIR=$(find "$OUTPUT" -maxdepth 2 -type d -name "Greybird*" | head -1)

if [ -z "$THEME_DIR" ]; then
    echo "Error: Could not find Greybird theme directory in archive"
    rm -rf "$OUTPUT"
    exit 1
fi

echo
echo "Installing..."
echo "--------------------------------------------------"

DIR_NAME=$(basename "$THEME_DIR")

if command -v sudo >/dev/null 2>&1; then
    sudo cp -R "$THEME_DIR" /usr/share/themes/
    sudo chmod -R 775 "/usr/share/themes/$DIR_NAME"
    sudo rm -rf /usr/share/themes/Greybird
    sudo ln -sf "/usr/share/themes/$DIR_NAME" /usr/share/themes/Greybird
elif command -v su >/dev/null 2>&1; then
    su root -c "cp -R '$THEME_DIR' /usr/share/themes/ && chmod -R 775 '/usr/share/themes/$DIR_NAME' && rm -rf /usr/share/themes/Greybird && ln -sf '/usr/share/themes/$DIR_NAME' /usr/share/themes/Greybird"
else
    echo "Error: need sudo or su for installation"
    rm -rf "$OUTPUT"
    exit 1
fi

echo
echo "Cleaning up..."
echo "--------------------------------------------------"
rm -rf "$OUTPUT"

echo "Done!"
