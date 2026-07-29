#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

if ! command -v unzip >/dev/null 2>&1; then
    echo "Error: unzip not found"
    exit 1
fi

TMPDIR=$(mktemp -d /tmp/papirus-amule-XXXXXX)
unzip -o "$SCRIPT_DIR/papirus_amule.zip" -d "$TMPDIR"

if command -v sudo >/dev/null 2>&1; then
    sudo cp -rf "$TMPDIR"/* /usr/share/pixmaps/
elif command -v su >/dev/null 2>&1; then
    su root -c "cp -rf $TMPDIR/* /usr/share/pixmaps/"
else
    echo "Error: need sudo or su for installation"
    rm -rf "$TMPDIR"
    exit 1
fi

rm -rf "$TMPDIR"
echo "Done! aMule Papirus icons installed to /usr/share/pixmaps/"
