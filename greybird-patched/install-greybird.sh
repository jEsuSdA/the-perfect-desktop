#!/bin/sh
clear 
echo
echo "=================================================="
echo "Usage: install-greybird.sh <greybird-theme-file.7z>"
echo "=================================================="
echo
echo

FILE=$1
DATE=`date +%Y%m%d`
OUTPUT="Greybird-$DATE"
DIR=$(basename "$FILE" ".7z")

echo
echo "Unzip Greybird..."
echo "--------------------------------------------------"
7za x "$FILE" -o$OUTPUT

echo
echo "Entering..."
echo "--------------------------------------------------"

cd $OUTPUT/


echo
echo "Installing and configuring..."
echo "--------------------------------------------------"

su root -c "cp -R $DIR /usr/share/themes/; chmod -R 775 /usr/share/themes/$DIR"


echo "Deleting..."

cd ../
rm -rf $OUTPUT


echo "Done!"
