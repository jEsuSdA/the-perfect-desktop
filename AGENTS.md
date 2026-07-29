# AGENTS.md — the-perfect-desktop

A Linux desktop customization collection by jEsuSdA. Shell scripts, GTK/icon/font themes, XFCE configs, compositors, wallpapers.

## Structure

- **No package.json, no lockfiles, no tests, no CI, no linters, no formatters.**
- Each directory is self-contained; there is no monorepo tool or shared build.

| Directory | What |
|-----------|------|
| `bashrc/` | `user.bashrc` (Solarized prompt, git status, Java font tweaks, GTK CSD disabled via `nocsd` preload) and `root.bashrc`. Install: `./install.sh` |
| `compositors/` | `compositor.sh` (manages picom/compton/fastcompmgr/xfwm4), plus `picom.conf`, `compton.conf`, and the **binary compositors themselves** (committed to git). Install: `sudo ./install.sh` |
| `cursors/` | Breeze cursor theme (`breeze_cursors.7z`). Install: `./install.sh` |
| `extra/` | Thunar custom actions (`thunar.uca.xml`) — Markdown conversions, PDF tools, etc. Install: `./install.sh` |
| `fonts/` | `fonts.conf` (hinting=true, autohint, rgb, DPI=120) + `.7z` font archives. Install: `./install.sh` |
| `greybird-patched/` | Patched Greybird GTK theme + `install-greybird.sh` + Firefox/Thunderbird userChrome |
| `kitty-terminal/` | `kitty.conf` (1318 lines, Adwaita Mono 9pt, tiled background, Tango colors). Install: `./install.sh` |
| `papirus-patched/` | `install-papirus.sh` (downloads latest or installs local archive, supports `hardcode-tray`) + 9 app-specific icon patches (aMule, Claws Mail, FBreader, gFTP, LibreOffice, MComix, Remarkable, Thunderbird tray, Zim) + XFCE4 Weather |
| `sound-theme/` | pasodoble OGG sounds + `install.sh` + `test-theme.sh` (uses `canberra-gtk-play`) + standalone notification OGG files for Thunderbird/calendar |
| `wallpapers/` | 108 images + `montage.sh` (ImageMagick montage). Install: `./install.sh` |
| `xfce-terminal/` | Terminal background images (terminal-background-night.png, terminal-background-day.png). Install: `./install.sh` |
| `xfwm4-themes/` | Window decoration themes (`.7z`). Install: `./install.sh` |

There is also a unified runner.

```sh
# Interactive installer (prompts per component)
./install-all.sh

# Unattended install of everything
./install-all.sh --all

# Install from local repo (no download)
./install-all.sh --local /path/to/repo
```

## Key commands

Individual scripts:

```sh
# Install Papirus icon theme (download mode)
sudo ./papirus-patched/install-papirus.sh --download

# Install Papirus icon theme (local archive)
sudo ./papirus-patched/install-papirus.sh --local papirus-20260728.tar.xz

# Install Greybird theme
sudo ./greybird-patched/install-greybird.sh Greybird-20260728.7z

# Install sound theme
sudo ./sound-theme/install.sh

# Test sound theme
./sound-theme/test-theme.sh

# Set compositor
./compositors/compositor.sh picom
./compositors/compositor.sh compton
./compositors/compositor.sh fastcompmgr
./compositors/compositor.sh xfwm4

# Build Claws Mail Papirus theme (subdirectory)
make -C papirus-patched/papirus-claws-mail build

# Create wallpaper montage
./wallpapers/montage.sh
```

## Environment quirks

- `/home/jesusda/Público/github/the-perfect-desktop` is a non-standard location (contains spaces, upper-case `Público`). Always use absolute paths or careful quoting.
- `bashrc/user.bashrc` expects `~/.opencode/bin` in PATH.
- Compositor binaries (`compositors/compton`, `compositors/picom`, `compositors/fastcompmgr`) are **committed to git**. They are not built from source here.
- `install-papirus.sh` can scrape GitHub HTML to find the latest release URL when `--download` is used — fragile by nature.
- `.gitignore` only exists under `papirus-patched/papirus-claws-mail/` (ignores `build/`). No root `.gitignore`.
