#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
PAPIRUS_DIR="/usr/share/icons/Papirus"

if [ ! -d "$PAPIRUS_DIR" ]; then
    echo "Error: Papirus icon theme not found at $PAPIRUS_DIR"
    echo "Install Papirus first, then run this script again."
    exit 1
fi

TMPDIR=$(mktemp -d /tmp/papirus-thunderbird-XXXXXX)
cp "$SCRIPT_DIR/inbox.svg" "$SCRIPT_DIR/inbox.png" "$TMPDIR"

if command -v sudo >/dev/null 2>&1; then
    for dir in "$PAPIRUS_DIR"/*/apps; do
        [ -d "$dir" ] && sudo cp -f "$TMPDIR"/* "$dir/"
    done
elif command -v su >/dev/null 2>&1; then
    su root -c "
        for dir in $PAPIRUS_DIR/*/apps; do
            [ -d \"\$dir\" ] && cp -f $TMPDIR/* \"\$dir/\"
        done
    "
else
    echo "Error: need sudo or su for installation"
    rm -rf "$TMPDIR"
    exit 1
fi

rm -rf "$TMPDIR"
echo "Done! Thunderbird tray icons installed to $PAPIRUS_DIR"
