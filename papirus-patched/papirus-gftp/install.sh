#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

cp -R "$SCRIPT_DIR/pixmaps" /tmp/pixmaps-dup

if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p /usr/share/gftp
    sudo cp -rf /tmp/pixmaps-dup/* /usr/share/gftp
elif command -v su >/dev/null 2>&1; then
    su root -c "mkdir -p /usr/share/gftp && cp -rf /tmp/pixmaps-dup/* /usr/share/gftp"
else
    echo "Error: need sudo or su for installation"
    rm -rf /tmp/pixmaps-dup
    exit 1
fi

rm -rf /tmp/pixmaps-dup
echo "Done!"
