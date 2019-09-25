#!/bin/sh

cp -R pixmaps pixmaps-dup
su root -c "cp -rf ./pixmaps-dup/* /usr/share/gftp && echo OK && exit"
rm pixmaps-dup -rf
read $tecla


