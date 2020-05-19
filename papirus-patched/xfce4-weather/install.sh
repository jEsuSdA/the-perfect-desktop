#!/bin/sh

cp -R icons icons-dup
su root -c "mv -f ./icons-dup/* /usr/share/xfce4/weather/icons/ && echo OK && exit"
rm icons-dup -rf
#read $tecla


