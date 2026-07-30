#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

cp -R "$SCRIPT_DIR/pixmaps" /tmp/pixmaps-dup

if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p /usr/share/zim/pixmaps/
    sudo mv -f /tmp/pixmaps-dup/* /usr/share/zim/pixmaps/
elif command -v su >/dev/null 2>&1; then
    su root -c "mkdir -p /usr/share/zim/pixmaps/ && mv -f /tmp/pixmaps-dup/* /usr/share/zim/pixmaps/"
else
    echo "Error: need sudo or su for installation"
    rm -rf /tmp/pixmaps-dup
    exit 1
fi

rm -rf /tmp/pixmaps-dup
echo "Done!"
