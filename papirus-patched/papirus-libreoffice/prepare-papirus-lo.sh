#!/bin/sh
clear 
echo
echo "=================================================="
echo "Usage: prepare-papirus-lo.sh"
echo "=================================================="
echo
echo

echo
echo "Preparing Papirus Sifr LibreOffice icon theme..."
echo "--------------------------------------------------"


mkdir temp
cd temp

cp /usr/share/libreoffice/share/config/images_sifr.zip .

unzip images_sifr.zip

rm images_sifr.zip

../sifr-transparent.sh

zip ../images_sifr.zip *

cd ..

rm -rf temp

./install-papirus-lo.sh



echo "Done!"
