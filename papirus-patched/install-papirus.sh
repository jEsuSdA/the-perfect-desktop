#!/bin/sh
clear 
echo
echo "=================================================="
echo "Usage: install-papirus.sh <papirus-theme-file.7z>"
echo "=================================================="
echo
echo

FILE=$1
DATE=`date +%Y%m%d`
OUTPUT="papirus-$DATE"
DIR=$(basename "$FILE" ".7z")

echo
echo "Unzip papirus..."
echo "--------------------------------------------------"
7za x "$FILE" -o$OUTPUT

echo
echo "Entering..."
echo "--------------------------------------------------"

cd $OUTPUT/$DIR/papirus-icon-theme-master/


echo
echo "Installing and configuring..."
echo "--------------------------------------------------"

su root -c "rm -rf /usr/share/icons/ePapirus ; rm -rf /usr/share/icons/Papirus ; rm -rf /usr/share/icons/Papirus-Dark ; rm -rf /usr/share/icons/Papirus-Light ; cp -R ePapirus Papirus Papirus-Dark Papirus-Light /usr/share/icons/ ; /usr/sbin/update-icon-caches /usr/share/icons/* ; chmod -R 775 /usr/share/icons/ePapirus ; chmod -R 775 /usr/share/icons/Papirus ; chmod -R 775 /usr/share/icons/Papirus-Dark ; chmod -R 775 /usr/share/icons/Papirus-Light"



echo "Applying hardcore-tray"

su root -c "sudo -E hardcode-tray --theme Papirus -s 22 --conversion-tool Inkscape --apply"



echo "Deleting..."

cd ../../../
rm -rf $OUTPUT


echo "Done!"
