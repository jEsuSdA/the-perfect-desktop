#!/bin/sh

red='\e[0;31m'
NC='\e[0m' # No Color



for i in alarm-clock-elapsed alarm audio-channel-front-center audio-channel-front-left audio-channel-front-right audio-channel-rear-center audio-channel-rear-left audio-channel-rear-right audio-channel-side-left audio-channel side-right audio-test-signal audio-volume-change bell button-toggle-off button-toggle-on camera-shutter complete desktop-login desktop-logout device-added device-removed dialog-error  dialog-information dialog-question dialog-warning message-new-instant message-new-mail message network-connectivity-established network-connectivity-lost phone-incoming-call phone-outgoing-busy phone-outgoing-calling power-plug power-unplug screen-capture service-login service-logout suspend-error system-ready trash-empty window-attention window-question window-slide
do

echo "$(tput setaf 1)PROBANDO MENSAJE: $i $(tput setaf 7)"
/usr/bin/canberra-gtk-play -i $i
/usr/bin/canberra-gtk-play --id="$i"

done


