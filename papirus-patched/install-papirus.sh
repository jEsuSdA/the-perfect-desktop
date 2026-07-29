#!/bin/bash
#
# install-papirus.sh
#
# Installs the patched Papirus/ePapirus icon themes to /usr/share/icons/.
#
# Two modes:
#   1. Download mode (no arguments):
#      Automatically finds and downloads the latest .tar.xz from the
#      GitHub repository, then installs it.
#
#   2. Local mode (one argument):
#      Installs from a .tar.xz file already on disk.
#
# Usage:
#   ./install-papirus.sh                         # download + install latest
#   ./install-papirus.sh papirus-20260728.tar.xz # install specific local file
#   ./install-papirus.sh /path/to/papirus-*.tar.xz
#
# Requires: tar, xz, and (for download mode) curl or wget
# Optional: hardcode-tray (auto-detected, requires Inkscape)
# Root access: already root → sudo (passwordless) → su → sudo (interactive)
#
# All temporary work happens in /tmp. Nothing is written to the
# directory the script lives in.

set -eo pipefail

# ── Config ──────────────────────────────────────────────────────────
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
ICONS_DIR="/usr/share/icons"
THEMES=(Papirus Papirus-Dark Papirus-Light ePapirus)

REPO_OWNER="jEsuSdA"
REPO_NAME="the-perfect-desktop"
REPO_BRANCH="master"
REPO_SUBDIR="papirus-patched"

# Colors for output
C_HEAD="\033[1;34m"
C_OK="\033[1;32m"
C_WARN="\033[1;33m"
C_ERR="\033[1;31m"
C_RST="\033[0m"

headline() { printf "\n${C_HEAD} ===> %s ${C_RST}\n" "$*"; }
ok()       { printf "${C_OK} [+] ${C_RST}%s\n" "$*"; }
warn()     { printf "${C_WARN} [!] ${C_RST}%s\n" "$*"; }
die()      { printf "${C_ERR} [-] %s ${C_RST}\n" "$*" >&2; exit 1; }

# ── Download helper ─────────────────────────────────────────────────
# download <url> <output_file>   → saves to file
# download <url> -               → outputs to stdout
download() {
    local url="$1"
    local out="$2"

    if command -v curl >/dev/null 2>&1; then
        if [[ "$out" == "-" ]]; then
            curl -fsSL "$url"
        else
            curl -fsSL "$url" -o "$out"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if [[ "$out" == "-" ]]; then
            wget -qO- "$url"
        else
            wget -qO "$out" "$url"
        fi
    else
        die "Neither curl nor wget found. Install one of them to proceed."
    fi
}

# ── Root access helper ──────────────────────────────────────────────
# Priority: su before sudo-interactive so users without sudo
# go straight to su (root password) without being asked for their
# user password.
SUDO_OPTS=""
run_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    elif sudo -n true 2>/dev/null; then
        sudo $SUDO_OPTS "$@"
    elif command -v su >/dev/null 2>&1; then
        local su_opts=""
        [[ "$SUDO_OPTS" == *-E* ]] && su_opts="-m"
        su $su_opts -c "$(printf '%q ' "$@")"
    elif command -v sudo >/dev/null 2>&1; then
        sudo $SUDO_OPTS "$@"
    else
        die "No root access method found (need sudo or su)"
    fi
}

# Check root access early
check_root() {
    if [[ $EUID -eq 0 ]]; then
        ok "Running as root"
    elif sudo -n true 2>/dev/null; then
        ok "Sudo available (passwordless)"
    elif command -v su >/dev/null 2>&1; then
        ok "Will use su for root access (will prompt for root password once)"
    elif command -v sudo >/dev/null 2>&1; then
        warn "Will use sudo for root access (will prompt for password during install)"
    else
        die "No root access method found (need sudo or su to install to $ICONS_DIR)"
    fi
}

# ── Usage info ──────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $0 [options] [archive.tar.xz]

Without arguments — downloads and installs the latest theme from GitHub.
With a file argument — installs the specified local .tar.xz archive.

Options:
  -h, --help     Show this help message

Examples:
  $0                              # download + install latest
  $0 papirus-20260728.tar.xz      # install local archive
  $0 /path/to/papirus-*.tar.xz    # install from absolute path

Requires: tar, xz (and curl or wget for download mode)
Optional: hardcode-tray (auto-detected, needs Inkscape)
EOF
}

# ── Parse arguments ─────────────────────────────────────────────────
ARCHIVE_INPUT=""
ORIG_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            [[ $# -gt 0 ]] && ARCHIVE_INPUT="$1" && ORIG_ARG="$1"
            break
            ;;
        -*)
            die "Unknown option: $1\n$(usage)"
            ;;
        *)
            ARCHIVE_INPUT="$1"
            ORIG_ARG="$1"
            shift
            break
            ;;
    esac
done

[[ $# -gt 0 ]] && die "Unexpected extra arguments: $*"

# ── Pre-flight checks ───────────────────────────────────────────────
headline "Pre-flight checks"

command -v tar >/dev/null || die "tar not found"
command -v xz  >/dev/null || die "xz not found (install xz-utils)"
ok "tar + xz available"

check_root

# ── Determine archive source ────────────────────────────────────────
TEMP_DIR="$(mktemp -d /tmp/papirus-install-XXXXXX)"
DOWNLOAD_FILE=""
INSTALL_SCRIPT="$(mktemp /tmp/papirus-install-XXXXXX.sh)"
HCT_SCRIPT="$(mktemp /tmp/papirus-hct-XXXXXX.sh)"

# Cleanup on exit, error, or interrupt
trap 'rm -rf "$TEMP_DIR" "$INSTALL_SCRIPT" "$HCT_SCRIPT" "$DOWNLOAD_FILE"' EXIT HUP INT TERM

if [[ -z "$ARCHIVE_INPUT" ]]; then
    # ── Download mode ────────────────────────────────────────────────
    headline "Downloading latest theme from GitHub"

    command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || \
        die "Neither curl nor wget found (needed for download mode)."

    TREE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/tree/${REPO_BRANCH}/${REPO_SUBDIR}"
    RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}/${REPO_SUBDIR}"

    ok "Searching for latest .tar.xz in repository..."
    ok "  $TREE_URL"

    # GitHub embeds the file listing as JSON inside the HTML page.
    # We scrape the HTML to find papirus-YYYYMMDD.tar.xz filenames.
    HTML_CONTENT="$(download "$TREE_URL" - 2>/dev/null)" || {
        die "Cannot reach GitHub repository page. Check your internet connection.

You can also download manually from:
  $TREE_URL
and run:  $0 <file.tar.xz>"
    }

    [[ -z "$HTML_CONTENT" ]] && die "Empty response from GitHub. Check your internet connection."

    # Extract the newest papirus-YYYYMMDD.tar.xz filename (YYYYMMDD sorts chronologically)
    LATEST_FILE="$(printf '%s' "$HTML_CONTENT" | grep -o 'papirus-[0-9]\{8\}\.tar\.xz' | sort -ru | head -1)"

    if [[ -z "$LATEST_FILE" ]]; then
        die "No .tar.xz archive found in repository.

This may happen if GitHub changed its page structure, or if no .tar.xz
has been uploaded yet. You can download manually from:
  $TREE_URL
and run:  $0 <file.tar.xz>"
    fi

    ok "Latest archive found: $LATEST_FILE"

    DOWNLOAD_URL="${RAW_BASE}/${LATEST_FILE}"
    DOWNLOAD_FILE="${TEMP_DIR}/${LATEST_FILE}"

    ok "Downloading: $DOWNLOAD_URL"
    download "$DOWNLOAD_URL" "$DOWNLOAD_FILE" || die "Download failed."

    # Validate it's a real .tar.xz (not an HTML error page)
    tar tJf "$DOWNLOAD_FILE" >/dev/null 2>&1 || die \
        "Downloaded file is not a valid .tar.xz archive.
This may happen if the file is corrupted or GitHub returned an error page."

    ARCHIVE_INPUT="$DOWNLOAD_FILE"
    ok "Downloaded: $(du -h "$DOWNLOAD_FILE" | cut -f1) → $LATEST_FILE"

else
    # ── Local mode ───────────────────────────────────────────────────
    # Resolve relative path: try as-is first, then relative to script dir
    if [[ ! -f "$ARCHIVE_INPUT" ]]; then
        ARCHIVE_INPUT="$SCRIPT_DIR/$ARCHIVE_INPUT"
    fi

    [[ -f "$ARCHIVE_INPUT" ]] || die "Archive not found: $ORIG_ARG"

    if [[ "$ARCHIVE_INPUT" != *.tar.xz ]]; then
        if [[ "$ARCHIVE_INPUT" == *.7z ]]; then
            die "This script only supports .tar.xz archives, but got: $(basename "$ORIG_ARG")

If you have an old .7z archive, extract it manually and copy the theme
folders to $ICONS_DIR/"
        fi
        die "File must be a .tar.xz archive: $(basename "$ORIG_ARG")"
    fi

    ok "Input: $ARCHIVE_INPUT"
fi

# ── Extract archive ─────────────────────────────────────────────────
headline "Extracting archive"
ok "Temp dir: $TEMP_DIR"

tar xJf "$ARCHIVE_INPUT" -C "$TEMP_DIR" || die "Extraction failed"
ok "Extracted successfully"

# ── Find theme directories ──────────────────────────────────────────
# Archives may have different structures:
#   papirus-YYYYMMDD/papirus-icon-theme-master/Papirus  (old format)
#   papirus-icon-theme-master/Papirus                    (new format)
#   Papirus                                               (flat)

declare -A THEME_PATHS

for theme in "${THEMES[@]}"; do
    found_path=""
    # Search for the theme directory at any depth
    while IFS= read -r -d '' match; do
        # Make sure it's a directory with an index.theme (not a nested copy)
        if [[ -f "$match/index.theme" ]]; then
            found_path="$match"
            break
        fi
    done < <(find "$TEMP_DIR" -type d -name "$theme" -print0 2>/dev/null)

    if [[ -n "$found_path" ]]; then
        THEME_PATHS["$theme"]="$found_path"
        ok "Found: $theme"
    else
        warn "Not found in archive: $theme"
    fi
done

# At least Papirus should be present
[[ -n "${THEME_PATHS[Papirus]}" ]] || die "Papirus theme not found in archive"
[[ -n "${THEME_PATHS[ePapirus]}" ]] || warn "ePapirus not found in archive (will install Papirus variants only)"

# ── Install themes ──────────────────────────────────────────────────
headline "Installing themes to $ICONS_DIR"

# Build a shell script with one command per line — each command is
# independent and cannot accidentally merge with the next.
{
    echo "#!/bin/bash"
    echo "set -e"
    echo ""
    echo "# Auto-generated by install-papirus.sh"
    echo "# Each rm/cp/chmod is on its own line — no batching with spaces."
    echo ""

    for theme in "${THEMES[@]}"; do
        path="${THEME_PATHS[$theme]}"
        if [[ -n "$path" && -d "$path" ]]; then
            # Safety guard: theme name must not be empty
            [[ -z "$theme" ]] && continue

            target="$ICONS_DIR/$theme"

            # Safety guard: target must be a subdirectory of ICONS_DIR,
            # never ICONS_DIR itself or a parent
            if [[ "$target" == "$ICONS_DIR" || "$target" == "$ICONS_DIR/" ]]; then
                warn "BUG DETECTED: refusing to rm '$target' — skipping $theme" >&2
                continue
            fi

            echo "# --- $theme ---"
            echo "rm -rf '$target'"
            echo "cp -R '$path' '$ICONS_DIR/'"
            echo "chmod -R 775 '$target'"
            echo ""
            ok "Queued: $theme" >&2
        fi
    done

    echo "# --- icon cache ---"
    for theme in "${THEMES[@]}"; do
        path="${THEME_PATHS[$theme]}"
        if [[ -n "$path" && -d "$path" ]]; then
            echo "gtk-update-icon-cache -q '$ICONS_DIR/$theme' 2>/dev/null || true"
        fi
    done
} > "$INSTALL_SCRIPT"

# Show the user exactly what will be executed as root
echo ""
echo "--- Script that will run as root ---"
cat "$INSTALL_SCRIPT"
echo "------------------------------------"
echo ""

run_root bash "$INSTALL_SCRIPT" || die "Installation failed"
ok "All themes installed and cache refreshed"

# ── Optional: hardcode-tray ─────────────────────────────────────────
if command -v hardcode-tray >/dev/null 2>&1; then
    headline "Hardcode-tray (optional)"
    warn "Running hardcode-tray (requires Inkscape for conversion)..."
    # Batch both hardcode-tray calls into a single root session.
    # Export user's PATH so Inkscape is found even under su (minimal PATH).
    {
        echo "#!/bin/bash"
        echo "export PATH=\"$PATH\""
        echo "hardcode-tray --theme Papirus -s 22 --conversion-tool Inkscape --apply || echo 'WARNING: hardcode-tray Papirus failed' >&2"
        echo "hardcode-tray --theme ePapirus -s 22 --conversion-tool Inkscape --apply || echo 'WARNING: hardcode-tray ePapirus failed' >&2"
    } > "$HCT_SCRIPT"
    run_root bash "$HCT_SCRIPT" || warn "hardcode-tray failed (non-fatal)"
    ok "hardcode-tray done"
else
    warn "hardcode-tray not installed — skipping"
fi

# ── Done ────────────────────────────────────────────────────────────
# (trap will clean up TEMP_DIR, INSTALL_SCRIPT, and downloaded file)
headline "Done!"
echo
echo "Installed from: $(basename "$ARCHIVE_INPUT")"
echo
installed_themes=""
for theme in "${THEMES[@]}"; do
    [[ -d "$ICONS_DIR/$theme" ]] && installed_themes="$installed_themes $theme"
done
echo "Themes installed:$installed_themes"
echo
echo "To change folder colors:"
echo "  papirus-folders -C <color> --theme ePapirus"
echo
echo "Available colors: blue, black, brown, carmine, cyan, deeporange,"
echo "  green, grey, indigo, magenta, orange, pink, red, teal, violet,"
echo "  white, yellow"
