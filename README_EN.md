# fcitx5-matugen-theme

**English** | [简体中文](README.md)

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Nix Flake](https://img.shields.io/badge/Nix-flake-5277C3.svg)](flake.nix)

Matugen-powered accent themes for Fcitx5 ClassicUI. The project keeps the rounded Mellow WeChat candidate window from [fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes), while deriving its highlight background and text colors from a Material You wallpaper palette.

Both light and dark variants are complete themes and work with ordinary ClassicUI candidate windows as well as GTK-embedded candidate windows rendered by fcitx5-gtk.

## Preview

| Light | Dark |
|---|---|
| `[Screenshot placeholder: preview/light.png]` | `[Screenshot placeholder: preview/dark.png]` |

Before publishing the final showcase, save the real-device screenshots as `preview/light.png` and `preview/dark.png`, then replace these placeholders with image links.

## Features

- Complete `mellow-matugen` and `mellow-matugen-dark` themes.
- Matugen `primary` for the rounded highlight and `on_primary` for highlighted text.
- Original Mellow WeChat panel geometry, shadows and spacing.
- Nix flake and distribution-independent manual installation.
- No dependency on Darkman, Waypaper or a particular desktop shell.

## How it works

Image-backed Fcitx5 highlights are not replaced by ordinary color fields, so this project renders both:

- `highlight.svg` from Matugen `primary`.
- A complete `theme.conf` with the original layout and `on_primary` text colors.

The complete file matters because fcitx5-gtk loads the first `theme.conf` found in the XDG search path and does not merge a user color fragment with a system theme.

## Installation

### Nix flake

```bash
nix profile install github:Shangshui0302/fcitx5-matugen-theme
```

As a Home Manager flake input:

```nix
inputs.fcitx5-matugen-theme = {
  url = "github:Shangshui0302/fcitx5-matugen-theme";
  inputs.nixpkgs.follows = "nixpkgs";
};

home.packages = [
  inputs.fcitx5-matugen-theme.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

The package installs themes under `share/fcitx5/themes/` and templates under:

```text
~/.nix-profile/share/matugen/fcitx5-matugen-theme/
```

### Generic Linux

```bash
git clone https://github.com/Shangshui0302/fcitx5-matugen-theme
cd fcitx5-matugen-theme

install -d ~/.local/share/fcitx5/themes ~/.config/matugen/templates/fcitx5-matugen-theme
cp -r themes/mellow-matugen themes/mellow-matugen-dark ~/.local/share/fcitx5/themes/
cp -r templates/. ~/.config/matugen/templates/fcitx5-matugen-theme/
```

## Matugen configuration

Add the four templates below to your Matugen configuration. Replace every path with an absolute path for your account:

```toml
[templates.fcitx5-light-theme]
input_path = "/home/USER/.config/matugen/templates/fcitx5-matugen-theme/mellow-matugen/theme.conf.tpl"
output_path = "/home/USER/.local/share/fcitx5/themes/mellow-matugen/theme.conf"

[templates.fcitx5-light-highlight]
input_path = "/home/USER/.config/matugen/templates/fcitx5-matugen-theme/mellow-matugen/highlight.svg.tpl"
output_path = "/home/USER/.local/share/fcitx5/themes/mellow-matugen/highlight.svg"

[templates.fcitx5-dark-theme]
input_path = "/home/USER/.config/matugen/templates/fcitx5-matugen-theme/mellow-matugen-dark/theme.conf.tpl"
output_path = "/home/USER/.local/share/fcitx5/themes/mellow-matugen-dark/theme.conf"

[templates.fcitx5-dark-highlight]
input_path = "/home/USER/.config/matugen/templates/fcitx5-matugen-theme/mellow-matugen-dark/highlight.svg.tpl"
output_path = "/home/USER/.local/share/fcitx5/themes/mellow-matugen-dark/highlight.svg"
```

Nix users can point `input_path` to the matching profile paths. Run Matugen normally afterwards:

```bash
matugen image /path/to/wallpaper.png -m dark -t scheme-content --prefer saturation
```

## Fcitx5 configuration

`~/.config/fcitx5/conf/classicui.conf` has no section header:

```ini
Theme=mellow-matugen-dark
DarkTheme=mellow-matugen-dark
UseDarkTheme=True
Vertical Candidate List=True
```

Set `Theme=mellow-matugen` in light mode and `Theme=mellow-matugen-dark` in dark mode. GTK Wayland clients read `Theme` directly, so changing only `DarkTheme` and `UseDarkTheme` is insufficient.

Restart Fcitx5 after a palette, wallpaper or mode change:

```bash
systemctl --user restart app-org.fcitx.Fcitx5@autostart.service \
  || fcitx5-remote --check -r
```

A Darkman hook typically renders Matugen, updates the current `Theme`, and restarts Fcitx5. This repository deliberately does not own the global light/dark state.

## Compatibility and limitations

- Requires Fcitx5 ClassicUI and Matugen.
- Your existing tooling remains responsible for mode state, wallpaper selection and reloads.
- GNOME Kimpanel, KDE Input Method Panel and similar external panels draw their own candidate window and do not use ClassicUI themes.
- Flatpak GTK applications must be able to read the user theme directory or host profile; sandbox permissions are outside this project.

## License and upstream

Licensed under the [BSD 2-Clause License](LICENSE). The original Mellow layout and SVG assets are copyrighted by sanweiya; see [NOTICE](NOTICE) for provenance and the source revision.

Upstream: [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
