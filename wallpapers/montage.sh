#!/bin/bash 

# Script que crea un montaje con todas las imágenes de frutas y verduras del proyecto
#
# By jEsuSdA 8)

mkdir temp

rm montaje.jpg

cp *.jpg temp

cd temp

for i in *.jpg
do

	mogrify -resize 800x600^ -gravity center -extent 800x600 "$i"

done

cd ..

mogrify -resize 100x100 temp/*.jpg

montage temp/*.jpg -geometry 100x100+7+7   montaje.jpg

rm -rf temp

# ;)

