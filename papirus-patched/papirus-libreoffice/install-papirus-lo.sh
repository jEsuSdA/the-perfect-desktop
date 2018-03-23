#!/bin/sh
clear 
echo
echo "=================================================="
echo "Usage: install-papirus-lo.sh"
echo "=================================================="
echo
echo

echo
echo "Installing and configuring..."
echo "--------------------------------------------------"

su root -c "cp -R images_sifr.zip /usr/share/libreoffice/share/config/; chmod -R 775 /usr/share/libreoffice/share/config/images_sifr.zip"

echo "Done!"
