# fcitx5-mellow-themes-matugen

**English** | [简体中文](README.md)

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Nix Flake](https://img.shields.io/badge/Nix-flake-5277C3.svg)](flake.nix)

See [CHANGELOG.md](CHANGELOG.md) for the release history.

Matugen-powered accent themes for Fcitx5 ClassicUI. The project keeps the rounded Mellow WeChat candidate window from [fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes), while deriving its highlight background and text colors from a Material You wallpaper palette.

Both light and dark variants are complete themes and work with ordinary ClassicUI candidate windows as well as GTK-embedded candidate windows rendered by fcitx5-gtk. Native blur is verified on Hyprland; niri, KWin and GNOME/Mutter are currently protocol-level theoretical support only. Issues and pull requests are welcome.

## Preview

Four wallpapers are shown in both light and dark modes, for eight Matugen palettes:

| Wallpaper | Light | Dark |
|---|---|---|
| Wallpaper 1 | ![Wallpaper 1 light](preview/wallpaper-1-light.png) | ![Wallpaper 1 dark](preview/wallpaper-1-dark.png) |
| Wallpaper 2 | ![Wallpaper 2 light](preview/wallpaper-2-light.png) | ![Wallpaper 2 dark](preview/wallpaper-2-dark.png) |
| Wallpaper 3 | ![Wallpaper 3 light](preview/wallpaper-3-light.png) | ![Wallpaper 3 dark](preview/wallpaper-3-dark.png) |
| Wallpaper 4 | ![Wallpaper 4 light](preview/wallpaper-4-light.png) | ![Wallpaper 4 dark](preview/wallpaper-4-dark.png) |

## Features

- Complete `mellow-matugen` and `mellow-matugen-dark` themes.
- Matugen `primary` for the rounded highlight and `on_primary` for highlighted text.
- Original Mellow WeChat panel geometry, shadows and spacing.
- Compositor-native background blur, verified on Hyprland; support status for other compositors is documented below.
- Nix flake and distribution-independent manual installation.
- The Home Manager module creates writable user theme copies by default, so Matugen can atomically update its color files.
- No dependency on Darkman, Waypaper or a particular desktop shell.

## How it works

Image-backed Fcitx5 highlights are not replaced by ordinary color fields, so this project renders both:

- `highlight.svg` from Matugen `primary`.
- `blur-mask.svg` to limit the compositor blur region and preserve rounded edges.
- A complete `theme.conf` with the original layout and `on_primary` text colors.

The complete file matters because fcitx5-gtk loads the first `theme.conf` found in the XDG search path and does not merge a user color fragment with a system theme.

## Installation

Installation is controlled by two choices:

- `themeSet`: `both`, `light` or `dark`;
- `style`: `blur` (current alpha `0.25`, requests compositor-native blur) or `solid` (opaque, no blur request).

The default combination is `both-blur`.

With Home Manager, the module also copies the selected complete themes to
`${XDG_DATA_HOME:-$HOME/.local/share}/fcitx5/themes/` by default. This user-owned directory is writable and is
where Matugen updates `theme.conf` and `highlight.svg`; the Nix profile package remains immutable.

### Generic Linux: manual copy

No installer is required. From the repository root, create the destination directories:

```bash
install -d ~/.local/share/fcitx5/themes \
  ~/.config/matugen/templates/fcitx5-matugen-theme
```

Install both light and dark blur themes:

```bash
cp -a themes/mellow-matugen themes/mellow-matugen-dark \
  ~/.local/share/fcitx5/themes/
cp -a templates/mellow-matugen templates/mellow-matugen-dark \
  ~/.config/matugen/templates/fcitx5-matugen-theme/
```

Matugen creates temporary files in the theme directories, so the runtime copies must be owned by the
current user and writable:

```bash
for d in ~/.local/share/fcitx5/themes/mellow-matugen*; do
  [ -d "$d" ] && chmod -R u+rwX "$d"
done
```

For only one mode, copy only the matching directory:

```bash
# Light only
cp -a themes/mellow-matugen ~/.local/share/fcitx5/themes/
cp -a templates/mellow-matugen ~/.config/matugen/templates/fcitx5-matugen-theme/

# Dark only
cp -a themes/mellow-matugen-dark ~/.local/share/fcitx5/themes/
cp -a templates/mellow-matugen-dark ~/.config/matugen/templates/fcitx5-matugen-theme/
```

For a solid variant, run this after copying the selected directories:

```bash
for d in ~/.local/share/fcitx5/themes/mellow-matugen*; do
  [ -d "$d" ] || continue
  sed -i \
    -e 's/^EnableBlur=True$/EnableBlur=False/' \
    -e 's/^BlurMask=blur-mask.svg$/BlurMask=/' \
    "$d/theme.conf"
  sed -i 's/fill-opacity:0.25/fill-opacity:1/g' "$d/panel.svg"
done
for f in ~/.config/matugen/templates/fcitx5-matugen-theme/mellow-matugen*/theme.conf.tpl; do
  [ -f "$f" ] || continue
  sed -i \
    -e 's/^EnableBlur=True$/EnableBlur=False/' \
    -e 's/^BlurMask=blur-mask.svg$/BlurMask=/' \
    "$f"
done
```

### Nix flake

Install the default both-mode blur theme:

```bash
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen
```

The single-mode and solid variants are also available:

```bash
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#light-blur
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#dark-blur
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#both-solid
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#light-solid
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#dark-solid
```

### Home Manager module

As a Home Manager flake input:

```nix
# flake.nix
inputs.fcitx5-matugen-theme = {
  url = "github:Shangshui0302/fcitx5-mellow-themes-matugen";
  inputs.nixpkgs.follows = "nixpkgs";
};

# home.nix
imports = [ inputs.fcitx5-matugen-theme.homeManagerModules.default ];

programs.fcitx5-matugen = {
  enable = true;
  themeSet = "both"; # "light", "dark" or "both"
  style = "blur";    # "solid" or "blur"
};
```

See [`examples/home-manager.nix`](examples/home-manager.nix) for a minimal module example.

The module installs the selected package and links the selected Matugen templates under:

```text
~/.config/matugen/templates/fcitx5-matugen-theme/
```

It also creates writable user copies of the selected themes under:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/fcitx5/themes/mellow-matugen*/
```

On first activation, existing read-only directories are migrated. For the same theme variant, existing
Matugen-generated `theme.conf` and `highlight.svg` files are preserved. Changing `themeSet` or `style`
refreshes the files managed by this project. To keep the profile-only behavior and manage the user
directory yourself, set:

```nix
programs.fcitx5-matugen.installRuntimeThemes = false;
```

The module does not overwrite `~/.config/fcitx5/conf/classicui.conf`; keep or set:

```ini
Theme=mellow-matugen
DarkTheme=mellow-matugen-dark
UseDarkTheme=True
Vertical Candidate List=True
```

When using `themeSet = "light"` or `"dark"`, align `Theme`/`DarkTheme` so Fcitx5 does not point at an uninstalled theme.

The public package variants are:

```text
both-blur (default)  light-blur  dark-blur
both-solid           light-solid dark-solid
```

Existing manual Matugen wiring can continue to be used; do not let the HM module and another module write the same `theme.conf`.

The package still stores themes under `share/fcitx5/themes/` and templates under:

```text
~/.nix-profile/share/matugen/fcitx5-matugen-theme/
```

If `installMatugenTemplates` is disabled, reference that profile path directly.

Do not symlink the runtime theme directory directly to a Nix profile: Matugen needs to create temporary
files there and atomically replace its outputs.

## Prompt for a General-Purpose Agent

If the user is unfamiliar with Fcitx5, Matugen or the current desktop environment, give the following prompt to a general-purpose agent. The agent should inspect existing configuration before changing it.

```text
Please install and configure this repository in the current Linux user environment:
https://github.com/Shangshui0302/fcitx5-mellow-themes-matugen

Goal: make both Fcitx5 ClassicUI and fcitx5-gtk GTK-embedded candidate windows use the rounded Mellow WeChat style, while deriving highlight background/text colors from Matugen primary/on_primary colors. Keep the candidate list vertical.

Work in this order:
1. Inspect the distribution, whether it is NixOS, installed Fcitx5/Fcitx5-gtk and Matugen, the current ClassicUI config, the Wayland compositor, existing light/dark mode manager, and XDG data paths.
2. First identify whether the user wants `both`, `light` or `dark`, and `blur` or `solid`; prefer the Flake/HM module on NixOS, and manual theme/template copying on other Linux systems. Do not use npm, pip or curl|sh.
3. Install only the selected complete theme directories. Do not create sparse theme.conf files containing only colors; GTK-embedded candidates need complete Metadata, Background, Highlight, image references and margins.
4. Add only the selected Matugen templates to the existing configuration: theme.conf and highlight.svg outputs must go to their matching user theme directories. Do not assume Darkman, Noctalia or Waypaper; reuse the user's existing mode and wallpaper manager.
5. Preserve unrelated settings in ~/.config/fcitx5/conf/classicui.conf, but ensure these keys are correct:
   Theme=mellow-matugen or mellow-matugen-dark (according to the current mode)
   DarkTheme=mellow-matugen-dark
   UseDarkTheme=True
   Vertical Candidate List=True
6. Back up existing configuration before editing and do not delete other themes. On NixOS, only edit Nix files in the configuration repository, show the diff, and let the user run rebuild/switch themselves.
7. Run Matugen once after configuration, restart or reload Fcitx5, and verify the native Wayland ClassicUI and GTK-embedded candidates on the current compositor. Hyprland is verified by this project; niri, KWin and GNOME/Mutter are theoretical support only and must not be reported as tested.
8. Report the installation method, files written, mode-switch command, wallpaper-switch command, verification result, and any command the user must run manually.
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

### Enabling compositor-native blur

The themes set `EnableBlur=True`, which asks Fcitx5 to request Wayland background blur. Use Fcitx5 5.1.20 or newer; older versions still load the theme but cannot request compositor-native blur.

Hyprland must enable input-method blur under `decoration:blur`:

```ini
decoration {
  blur {
    enabled = true
    input_methods = true
    new_optimizations = true
  }
}
```

In theory, niri only needs global blur enabled; it is not tested by this project. Do not try to match Fcitx5 with an ordinary `popups` rule:

```kdl
blur {
    passes 3
    offset 3
    noise 0.02
    saturation 1.5
}
```

In theory, KWin needs its desktop Blur effect enabled. GNOME/Mutter provides compositor-native blur only in versions that support `ext-background-effect`; neither is tested by this project, and unsupported versions gracefully fall back to the regular theme.

Verification status: native blur is verified on Hyprland in this project. niri, KWin and GNOME/Mutter have not been tested here and are protocol-level theoretical support only. If you validate one of them, please open an issue or pull request with the Fcitx5/compositor versions and screenshots.

## Compatibility and limitations

- Requires Fcitx5 ClassicUI and Matugen.
- Your existing tooling remains responsible for mode state, wallpaper selection and reloads.
- Wayland-native blur depends on compositor support; Hyprland needs `input_methods=true` and is verified here. niri, KWin and GNOME/Mutter are currently untested theoretical support only.
- `fcitx5-gtk` GTK3/GTK4 candidate windows keep the theme colors and layout, but compositor backdrop blur is not guaranteed.
- GNOME Kimpanel, KDE Input Method Panel and similar external panels draw their own candidate window and do not use ClassicUI themes.
- Flatpak GTK applications must be able to read the user theme directory or host profile; sandbox permissions are outside this project.

## License and upstream

Licensed under the [BSD 2-Clause License](LICENSE). The original Mellow layout and SVG assets are copyrighted by sanweiya; see [NOTICE](NOTICE) for provenance and the source revision.

Upstream: [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
