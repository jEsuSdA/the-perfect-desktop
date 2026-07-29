#!/bin/sh

set -e

gh_repo="papirus-claws-mail-theme"
gh_desc="Papirus icons for Claws Mail"

cat <<- EOF



      ppppp                         ii
      pp   pp     aaaaa   ppppp          rr  rrr   uu   uu     sssss
      ppppp     aa   aa   pp   pp   ii   rrrr      uu   uu   ssss
      pp        aa   aa   pp   pp   ii   rr        uu   uu      ssss
      pp          aaaaa   ppppp     ii   rr          uuuuu   sssss
                          pp
                          pp


  $gh_desc
  https://github.com/PapirusDevelopmentTeam/$gh_repo


EOF

: "${DESTDIR:=/usr/share/claws-mail/themes}"
: "${TAG:=master}"
: "${THEMES:=Papirus ePapirus Papirus-Dark Papirus-Light}"
: "${uninstall:=false}"

_msg() {
    echo "=>" "$@" >&2
}

_rm() {
    # backup before removal
    if [ -d "$1" ]; then
        _sudo mv -f "$1" "$1.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
    fi
    # removes parent directories if empty
    _sudo rmdir -p "$(dirname "$1")" 2>/dev/null || true
}

_sudo() {
    if [ -w "$DESTDIR" ] || [ -w "$(dirname "$DESTDIR")" ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    elif command -v su >/dev/null 2>&1; then
        su root -c "$*"
    else
        echo "Error: need sudo or su for installation" >&2
        exit 1
    fi
}

_download() {
    _msg "Getting the latest version from GitHub ..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$temp_file" \
            "https://github.com/PapirusDevelopmentTeam/$gh_repo/archive/$TAG.tar.gz"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_file" \
            "https://github.com/PapirusDevelopmentTeam/$gh_repo/archive/$TAG.tar.gz"
    else
        echo "Error: need curl or wget for download" >&2
        exit 1
    fi
    _msg "Unpacking archive ..."
    tar -xzf "$temp_file" -C "$temp_dir"
}

_uninstall() {
    for theme in "$@"; do
        test -d "$DESTDIR/$theme" || continue
        _msg "Deleting '$theme' ..."
        _rm "$DESTDIR/$theme"
    done
}

_install() {
    _sudo mkdir -p "$DESTDIR"

    for theme in "$@"; do
        test -d "$temp_dir/$gh_repo-$TAG/$theme" || continue
        _msg "Installing '$theme' ..."
        _sudo cp -R "$temp_dir/$gh_repo-$TAG/$theme" "$DESTDIR"
    done
}

_cleanup() {
    _msg "Clearing cache ..."
    rm -rf "$temp_file" "$temp_dir"
    _msg "Done!"
}

trap _cleanup EXIT HUP INT TERM

temp_file="$(mktemp -u)"
temp_dir="$(mktemp -d)"

if [ "$uninstall" = "false" ]; then
    _download
    _uninstall $THEMES
    _install $THEMES
else
    _uninstall $THEMES
fi
