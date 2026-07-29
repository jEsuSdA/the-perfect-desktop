#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

echo
echo "Preparing Papirus Sifr LibreOffice icon theme..."
echo "--------------------------------------------------"

TEMP_DIR=$(mktemp -d /tmp/papirus-lo-XXXXXX)

cp /usr/share/libreoffice/share/config/images_sifr.zip "$TEMP_DIR/"

cd "$TEMP_DIR"
unzip images_sifr.zip
rm images_sifr.zip

"$SCRIPT_DIR/sifr-transparent.sh"

zip "$SCRIPT_DIR/images_sifr.zip" ./*

cd /
rm -rf "$TEMP_DIR"

"$SCRIPT_DIR/install-papirus-lo.sh"

echo "Done!"
