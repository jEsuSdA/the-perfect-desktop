#!/bin/sh
set -e

command -v sed >/dev/null 2>&1 || { echo "Error: sed not found"; exit 1; }

OLDCOLOR=dfdfdf
NEWCOLOR=6e6e6e

for f in 128/*.png; do
    [ -f "$f" ] || continue
    sed -i s/$OLDCOLOR/$NEWCOLOR/g "$f"
done

for f in 48/*.png; do
    [ -f "$f" ] || continue
    sed -i s/$OLDCOLOR/$NEWCOLOR/g "$f"
done
