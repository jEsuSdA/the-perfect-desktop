#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
ARCHIVE="$SCRIPT_DIR/images_sifr.zip"

[ -f "$ARCHIVE" ] || { echo "Error: $ARCHIVE not found"; exit 1; }

echo
echo "Installing Papirus Sifr LibreOffice icon theme..."
echo "--------------------------------------------------"

if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p /usr/share/libreoffice/share/config/
    sudo cp "$ARCHIVE" /usr/share/libreoffice/share/config/
    sudo chmod 644 /usr/share/libreoffice/share/config/images_sifr.zip
elif command -v su >/dev/null 2>&1; then
    su root -c "mkdir -p /usr/share/libreoffice/share/config/ && cp '$ARCHIVE' /usr/share/libreoffice/share/config/ && chmod 644 /usr/share/libreoffice/share/config/images_sifr.zip"
else
    echo "Error: need sudo or su for installation"
    exit 1
fi

echo "Done!"
