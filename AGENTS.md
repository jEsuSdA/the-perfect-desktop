# AGENTS.md — the-perfect-desktop

A Linux desktop customization collection by jEsuSdA. Shell scripts, GTK/icon/font themes, XFCE configs, compositors, wallpapers.

## Structure

- **No package.json, no lockfiles, no tests, no CI, no linters, no formatters.**
- Each directory is self-contained; there is no monorepo tool or shared build.

| Directory | What |
|-----------|------|
| `bashrc/` | `user.bashrc` (Solarized prompt, git status, Java font tweaks, GTK CSD disabled via `nocsd` preload) and `root.bashrc` |
| `compositors/` | `compositor.sh` (manages picom/compton/fastcompmgr/xfwm4), plus `picom.conf`, `compton.conf`, and the **binary compositors themselves** (committed to git) |
| `cursors/` | Breeze cursor theme (`breeze_cursors.7z`) |
| `extra/` | Thunar custom actions (`thunar.uca.xml`) — Markdown conversions, PDF tools, etc. |
| `fonts/` | `fonts.conf` (hinting=true, autohint, rgb, DPI=120) + `.7z` font archives |
| `greybird-patched/` | Patched Greybird GTK theme + `install-greybird.sh` + Firefox/Thunderbird userChrome |
| `kitty-terminal/` | `kitty.conf` (1318 lines, Adwaita Mono 9pt, tiled background, Tango colors) |
| `papirus-patched/` | `install-papirus.sh` (downloads latest or installs local archive, supports `hardcode-tray`) + app-specific icon patches (Claws Mail, aMule, LibreOffice, etc.) |
| `sound-theme/` | pasodoble OGG sounds + `install.sh` + `test-theme.sh` (uses `canberra-gtk-play`) |
| `wallpapers/` | 108 images + `montage.sh` (ImageMagick montage) |
| `xfwm4-themes/` | Window decoration themes (`.7z`) |

## Key commands

All scripts are standalone. No unified runner.

```sh
# Install Papirus icon theme (download mode)
sudo ./papirus-patched/install-papirus.sh --download

# Install Papirus icon theme (local archive)
sudo ./papirus-patched/install-papirus.sh --local papirus-20260728.tar.xz

# Install Greybird theme
sudo ./greybird-patched/install-greybird.sh

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
