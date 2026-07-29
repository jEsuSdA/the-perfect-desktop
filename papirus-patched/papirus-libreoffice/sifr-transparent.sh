#!/bin/bash
set -e

command -v convert >/dev/null 2>&1 || { echo "Error: ImageMagick (convert) not found"; exit 1; }

transparent() {
    for f in *.png; do
        [ -f "$f" ] || continue
        convert "$f" -fuzz 20% -transparent white "$f"
    done
}

CDIR=$(pwd)

while IFS= read -r DIR; do
    cd "$DIR"
    transparent
    cd "$CDIR"
done < <(find . -type d)
