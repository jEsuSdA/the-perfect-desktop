# Papirus-patched Icon Theme

Patched version of the [Papirus icon theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/) with extras, plus the ePapirus variant (removed from official releases).

![Icons preview](screenshot-icons.png)

## Installation

### Download and install latest

```sh
sudo ./install-papirus.sh --download
```

### Install from local archive

```sh
sudo ./install-papirus.sh --local papirus-20260728.tar.xz
```

The script supports `hardcode-tray` integration and auto-elevates with `sudo` or `su`.

## App-specific patches

| Directory | App | Notes |
|-----------|-----|-------|
| `papirus-amule/` | aMule | Custom icons |
| `papirus-claws-mail/` | Claws Mail | Full theme with Makefile build system (`make -C build`) |
| `papirus-fbreader/` | FBreader | Includes install script |
| `papirus-gftp/` | gFTP | Includes install script |
| `papirus-inkscape-windows/` | Inkscape (Windows) | Icon theme for Windows Inkscape |
| `papirus-libreoffice/` | LibreOffice | Sifr icon theme with transparency fixes |
| `papirus-mcomix/` | MComix | Includes install script |
| `papirus-remarkable/` | Remarkable | Includes install script |
| `papirus-thunderbird-tray/` | Thunderbird tray | `inbox.png` / `inbox.svg` for Thunderbird tray icon |
| `papirus-zim/` | Zim desktop wiki | Includes install script |
| `xfce4-weather/` | XFCE Weather plugin | Weather condition icons |
| `gimp-splash.png` | Splash Image for GIMP | Copy into `~/.config/GIMP/3.0/splashes/` |

