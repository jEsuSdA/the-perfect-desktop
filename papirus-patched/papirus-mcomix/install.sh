#!/bin/sh

cp -R images images-dup
su root -c "cp -rf ./images-dup/* /usr/lib/python2.7/dist-packages/mcomix/images/ && echo OK && exit"
rm images-dup -rf
read $tecla

