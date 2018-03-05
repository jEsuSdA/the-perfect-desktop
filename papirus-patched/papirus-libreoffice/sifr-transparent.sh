#!/bin/bash


function transparent {

	for i in *.png
	do

		convert "$i" -fuzz 20% -transparent white "$i"
		#convert "$i" -fuzz 5% -transparent "#c8c9c8" "$i"

	done
}


CDIR=$(pwd)
for i in $(ls -R | grep :); do
    DIR=${i%:}                    # Strip ':'
    cd $DIR
    transparent
    cd $CDIR
done
