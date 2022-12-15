#!/bin/sh

OLDCOLOR=dfdfdf
NEWCOLOR=6e6e6e

#cp -r Symbolic Symbolic_temp

sh -c "sed -i s/$OLDCOLOR/$NEWCOLOR/g 128/*.png"

#OLDCOLOR=6e6e6

sh -c "sed -i s/$OLDCOLOR/$NEWCOLOR/g 48/*.png"
#sh -c "sed -i s/$OLDCOLOR/$NEWCOLOR/g 22/*.png"

#cp -r Base Symbolic_pasodoble


