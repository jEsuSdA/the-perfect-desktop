#!/bin/sh
set -e

SCRIPT_DIR=$(dirname "$0")

run_root() {
    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    elif command -v su >/dev/null 2>&1; then
        su root -c "$*"
    else
        echo "Error: need sudo or su for installation"
        exit 1
    fi
}

echo "Installing compositors..."

for bin in picom compton fastcompmgr; do
    if [ -f "$SCRIPT_DIR/$bin" ]; then
        if [ -f "/usr/local/bin/$bin" ]; then
            TIMESTAMP=$(date +%Y%m%d%H%M%S)
            run_root cp "/usr/local/bin/$bin" "/usr/local/bin/$bin.bak.$TIMESTAMP"
            echo "  ✔ Backup: /usr/local/bin/$bin.bak.$TIMESTAMP"
        fi
        run_root cp "$SCRIPT_DIR/$bin" /usr/local/bin/
        run_root chmod 755 "/usr/local/bin/$bin"
        echo "  ✔ $bin → /usr/local/bin/"
    fi
done

run_root cp "$SCRIPT_DIR/compositor.sh" /usr/local/bin/
run_root chmod 755 /usr/local/bin/compositor.sh
echo "  ✔ compositor.sh → /usr/local/bin/"

mkdir -p "$HOME/.config"
    for conf in picom.conf compton.conf; do
        if [ -f "$SCRIPT_DIR/$conf" ]; then
            if [ -f "$HOME/.config/$conf" ]; then
                TIMESTAMP=$(date +%Y%m%d%H%M%S)
                cp "$HOME/.config/$conf" "$HOME/.config/$conf.bak.$TIMESTAMP"
                echo "  ✔ Backup: ~/.config/$conf.bak.$TIMESTAMP"
            fi
            cp "$SCRIPT_DIR/$conf" "$HOME/.config/$conf"
            echo "  ✔ $conf → ~/.config/"
        fi
    done

echo "Done! Run 'compositor.sh picom' to start."
