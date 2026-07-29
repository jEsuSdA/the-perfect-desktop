#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

cp -R "$SCRIPT_DIR/icons" /tmp/icons-dup

if command -v sudo >/dev/null 2>&1; then
    sudo mv -f /tmp/icons-dup/* /usr/share/xfce4/weather/icons/
elif command -v su >/dev/null 2>&1; then
    su root -c "mv -f /tmp/icons-dup/* /usr/share/xfce4/weather/icons/"
else
    echo "Error: need sudo or su for installation"
    rm -rf /tmp/icons-dup
    exit 1
fi

rm -rf /tmp/icons-dup
echo "Done!"
