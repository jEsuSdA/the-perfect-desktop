#!/bin/sh

cp -R pasodoble pasodoble-dup
su root -c "mkdir /usr/share/sounds/pasodoble && mv -f ./pasodoble-dup/* /usr/share/sounds/pasodoble/ && gconftool-2 -s /desktop/gnome/sound/theme_name "pasodoble" -t string && gconftool -s /desktop/gnome/sound/theme_name "pasodoble" -t string && echo OK && exit"

gconftool-2 -s /desktop/gnome/sound/theme_name "pasodoble" -t string 
gconftool -s /desktop/gnome/sound/theme_name "pasodoble" -t string && echo OK

rm pasodoble-dup -rf
read $tecla


