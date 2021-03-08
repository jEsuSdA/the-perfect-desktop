#!/bin/sh

cp -R pixmaps pixmaps-dup
su root -c "mv -f ./pixmaps-dup/* /usr/share/zim/pixmaps/ && echo OK && exit"
rm pixmaps-dup -rf
read tecla


