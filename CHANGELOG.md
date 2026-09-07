# Changelog

## Unreleased

- The Home Manager module now creates writable user copies under the XDG data directory for Matugen's runtime `theme.conf` and `highlight.svg` updates.
- Existing read-only manual copies are migrated without replacing generated colors; changing the selected theme variant refreshes managed assets.
- Simplified the Home Manager example and documented the runtime-directory ownership boundary.

## 0.2.0 - 2026-09-06

- Added compositor-native blur themes with a rounded `blur-mask.svg`.
- Added blur and solid package variants for both, light-only and dark-only installs.
- Added a Home Manager module with `themeSet`, `style` and template-install options.
- Added package output-contract checks and GitHub Actions Nix CI.
- Documented Hyprland as verified; niri, KWin and GNOME/Mutter remain theoretical support.

## 0.1.0

- Initial Matugen-aware Mellow Fcitx5 themes and manual/Nix installation paths.
