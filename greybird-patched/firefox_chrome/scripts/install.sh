#!/bin/bash

THEMEDIRECTORY=$(cd `dirname $0` && cd .. && pwd)
FIREFOXFOLDER=~/.mozilla/firefox
PROFILENAME=""


# Get options.
while getopts 'f:p:g:t:h' flag; do
	case "${flag}" in
	f) FIREFOXFOLDER="${OPTARG}" ;;
	p) PROFILENAME="${OPTARG}" ;;
	h)
		echo "Firefox Papirus Icon Theme Install Script:"
		echo "  -f <firefox_folder_path>. Set custom Firefox folder path."
		echo "  -p <profile_name>. Set custom profile name."
		echo "  -h to show this message."
		exit 0
		;;
	esac
done

function saveProfile(){
	local PROFILE_PATH="$1"

	cd "$FIREFOXFOLDER/$PROFILE_PATH"
	echo "Installing theme in $PWD"
	# Create a chrome directory if it doesn't exist.
	mkdir -p chrome
	cd chrome

	# Copy theme repo inside
	echo "Copying repo in $PWD"
	cp -fR "$THEMEDIRECTORY" "$PWD"

	# Create single-line user CSS files if non-existent or empty.
	if [ -s userChrome.css ]; then
		# Remove older theme imports
		sed 's/@import "firefox-papirus-icon-theme.*.//g' userChrome.css | sed '/^\s*$/d' > userChrome.css
		echo >> userChrome.css
	else
		echo >> userChrome.css
	fi

	# Import this theme at the beginning of the CSS files.
	sed -i '1s/^/@import "firefox-papirus-icon-theme\/userChrome.css";\n/' userChrome.css

	cd ..

	# Symlink user.js to firefox-papirus-icon-theme one.
	echo "Set configuration user.js file"
	ln -fs chrome/firefox-papirus-icon-theme/configuration/user.js user.js

	echo "Done."
	cd ..
}

PROFILES_FILE="${FIREFOXFOLDER}/profiles.ini"
if [ ! -f "${PROFILES_FILE}" ]; then
	>&2 echo "failed, please check Firefox installation, unable to find profile.ini at ${FIREFOXFOLDER}"
	exit 1
fi
echo "Profiles file found"

PROFILES_PATHS=($(grep -E "^Path=" "${PROFILES_FILE}" | tr -d '\n' | sed -e 's/\s\+/SPACECHARACTER/g' | sed 's/Path=/::/g' )) 
PROFILES_PATHS+=::

PROFILES_ARRAY=()
if [ "${PROFILENAME}" != "" ];
	then
		echo "Using ${PROFILENAME} theme"
		PROFILES_ARRAY+=${PROFILENAME}
else
	echo "Finding all avaliable themes";
	while [[ $PROFILES_PATHS ]]; do
		PROFILES_ARRAY+=( "${PROFILES_PATHS%%::*}" )
		PROFILES_PATHS=${PROFILES_PATHS#*::}
	done
fi



if [ ${#PROFILES_ARRAY[@]} -eq 0 ]; then
	echo No Profiles found on $PROFILES_FILE;

else
	for i in "${PROFILES_ARRAY[@]}"
	do
		if [[ ! -z "$i" ]];
		then
			echo Installing Theme on $(sed 's/SPACECHARACTER/ /g' <<< $i) ;
			saveProfile "$(sed 's/SPACECHARACTER/ /g' <<< $i)"
		fi;
	
	done
fi
