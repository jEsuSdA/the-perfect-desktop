# Activate sound theme in XFCE


## 1 Install sound theme:

Run install.sh or copy pasodoble folder into 

	/usr/share/sounds/


## 2 Install packages:

	apt-get install dconf-tools sound-theme-freedesktop xfconf pavucontrol
	apt-get install sox gnome-session-canberra at-spi2-core xdg-utils

## 3 Test loaded camberra-gtk-modules 

In terminal:

	echo $GTK_MODULES

You should watch something like that:

	$ → echo $GTK_MODULES
	gail:atk-bridge:canberra-gtk-module


If "canberra-gtk-module" does not appears, you should force load this module doing that:



Create file

	/etc/X11/Xsession.d/52libcanberra-gtk3-module_add-to-gtk-modules


Edit and copy this inside 52libcanberra-gtk3-module_add-to-gtk-modules


	# -*- sh -*-
	# Xsession.d script to set the GTK_MODULES env variable to load atk
	#
	# This file is sourced by Xsession(5), not executed.

	if [ -z "$GTK_MODULES" ] ; then
		GTK_MODULES="canberra-gtk-module"
	else
		GTK_MODULES="$GTK_MODULES:canberra-gtk-module"
	fi

	export GTK_MODULES




After doing that and re-login, you must see this 

	gail:atk-bridge:canberra-gtk-module

after typing

	echo $GTK_MODULES



---

This may work, but if don't, you can try:

Create the file 

	/etc/profile.d/gtk-modules-camberra.sh

with thist content:

	#!/bin/sh
	export GTK_MODULES=$GTK_MODULES:canberra-gtk-module


Make it executable (as root)

	chmod +x /etc/profile.d/gtk-modules-camberra.sh



Or you can do this creating a .gtkrc-2.0 file in your $HOME with the following contents:

	~.gtk-2.0

	gtk-modules = "canberra-gtk-module"


	gtk-enable-event-sounds=1
	gtk-enable-input-feedback-sounds=1
	gtk-sound-theme-name=pasodoble



Or putting 

	export GTK_MODULES=$GTK_MODULES:canberra-gtk-module

in your 

	~/.xprofile or ~/.xinitrc





## 4 Enable event sounds

Check "Enable event sounds" in Settings Manager → Appearance → Settings tab;


![Screenshot](xfce-settings0.png  "Title")


	gconftool-2 -s /desktop/gnome/sound/theme_name "pasodoble" -t string 
	gconftool -s /desktop/gnome/sound/theme_name "pasodoble" -t string


Go to deconf-editor > /org/gnome/desktop/sound.

Make sure the Event Sounds & feedback sounds boxes are ticked.
Then change the theme name to "pasodoble" (without the quotes)


![Screenshot](xfce-settings3.png  "Title")


Do the same with gconf-editor


![Screenshot](xfce-settings4.png  "Title")


## 5 Select 'pasodoble' sound theme

In the Settings Editor set "xsettings/Net/SoundThemeName" to a sound theme located in /usr/share/sounds/


![Screenshot](xfce-settings1.png  "Title")



## 6 Extra

Test your System Sounds volume is high enough


![Screenshot](xfce-settings2.png  "Title")

May be you have to turn on "System Sounds" in audio mixer (e.g. pavucontrol)




## 7 Testing

After reboot, you can test:


	/usr/bin/canberra-gtk-play -i trash-empty


Or using test-theme-global.sh script



## Extra

### Activate sound on terminal 

Go to 
	
	.config/Terminal/

Open terminalrc in a text editor.
Find the MiscBell setting, and change it to TRUE.


In XFCE do the same with 

	.config/xfce4/terminal/terminalrc


	MiscBell=TRUE



Edit 
	/etc/pulse/default.pa 

and add the following to the bottom of the file:

	# audible bell
	load-sample-lazy x11-bell /usr/share/sounds/pasodoble/stereo/bell.ogg
	load-module module-x11-bell sample=x11-bell

Restart PulseAudio

	pulseaudio -k

And that's all! You can ear a nice sound as a bell in Terminal. :D




### gtk3

Another thing you may try if you don't want to go to the gnome-settings-daemon route is create 

	~.config/gtk-3.0/settings.ini 

	[Settings]
	gtk-enable-event-sounds=1
	gtk-enable-input-feedback-sounds=1
	gtk-sound-theme-name=pasodoble



## More info

- https://wiki.archlinux.org/index.php/Xfce#Sound_themes
- https://old.reddit.com/r/xfce/comments/booaz3/how_to_make_notifications_play_a_sound/
- https://wiki.archlinux.org/index.php/Libcanberra

