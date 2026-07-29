#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")
TIMESTAMP=$(date +%Y%m%d%H%M%S)

backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak.$TIMESTAMP"
        echo "  ✔ Backup: $1 → $1.bak.$TIMESTAMP"
    fi
}

echo "Installing bashrc files..."

backup_file "$HOME/.bashrc"
cp "$SCRIPT_DIR/user.bashrc" "$HOME/.bashrc"
echo "  ✔ user.bashrc → ~/.bashrc"

if command -v sudo >/dev/null 2>&1; then
    backup_file "/root/.bashrc"
    sudo cp "$SCRIPT_DIR/root.bashrc" /root/.bashrc
    echo "  ✔ root.bashrc → /root/.bashrc"
else
    echo "  ⚠ sudo not available; skipping root.bashrc"
fi

echo "Done! Restart your shell or run: source ~/.bashrc"
