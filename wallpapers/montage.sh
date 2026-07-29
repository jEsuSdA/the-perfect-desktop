#!/bin/bash
set -e

trap 'rm -rf temp' EXIT HUP INT TERM

mkdir -p temp
rm -f montaje.jpg

for f in *.jpg; do
    [ -f "$f" ] || continue
    cp "$f" temp/
done

cd temp

for i in *.jpg; do
    [ -f "$i" ] || continue
    mogrify -resize 800x600^ -gravity center -extent 800x600 "$i"
done

cd ..

HAS_FILES=false
for f in temp/*.jpg; do
    [ -f "$f" ] && HAS_FILES=true
done

if [ "$HAS_FILES" = true ]; then
    mogrify -resize 100x100 temp/*.jpg
    montage temp/*.jpg -geometry 100x100+7+7   montaje.jpg
fi
