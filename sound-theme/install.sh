#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

echo "Installing pasodoble sound theme..."

cp -R "$SCRIPT_DIR/pasodoble" /tmp/pasodoble-dup

if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p /usr/share/sounds/pasodoble
    sudo rm -rf /usr/share/sounds/pasodoble
    sudo mkdir -p /usr/share/sounds/pasodoble
    sudo mv -f /tmp/pasodoble-dup/* /usr/share/sounds/pasodoble/
elif command -v su >/dev/null 2>&1; then
    su root -c "mkdir -p /usr/share/sounds/pasodoble && rm -rf /usr/share/sounds/pasodoble && mkdir -p /usr/share/sounds/pasodoble && mv -f /tmp/pasodoble-dup/* /usr/share/sounds/pasodoble/"
else
    echo "Error: need sudo or su for installation"
    rm -rf /tmp/pasodoble-dup
    exit 1
fi

rm -rf /tmp/pasodoble-dup

gconftool-2 -s /desktop/gnome/sound/theme_name "pasodoble" -t string 2>/dev/null || true
gconftool -s /desktop/gnome/sound/theme_name "pasodoble" -t string 2>/dev/null || true

echo "Done!"
