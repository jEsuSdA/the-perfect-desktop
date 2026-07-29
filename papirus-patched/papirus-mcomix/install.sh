#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

cp -R "$SCRIPT_DIR/images" /tmp/images-dup

if command -v sudo >/dev/null 2>&1; then
    sudo cp -rf /tmp/images-dup/* /usr/lib/python2.7/dist-packages/mcomix/images/
    sudo cp -rf /tmp/images-dup/* /usr/share/mcomix/mcomix/images/
elif command -v su >/dev/null 2>&1; then
    su root -c "cp -rf /tmp/images-dup/* /usr/lib/python2.7/dist-packages/mcomix/images/ && cp -rf /tmp/images-dup/* /usr/share/mcomix/mcomix/images/"
else
    echo "Error: need sudo or su for installation"
    rm -rf /tmp/images-dup
    exit 1
fi

rm -rf /tmp/images-dup
echo "Done!"
