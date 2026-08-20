# fcitx5-matugen-theme

[English](README_EN.md) | **简体中文**

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Nix Flake](https://img.shields.io/badge/Nix-flake-5277C3.svg)](flake.nix)

为 Fcitx5 ClassicUI 制作的 Matugen 动态重点色主题。它保留
[fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
中 Mellow WeChat 的圆角候选窗，同时让高亮背景和文字随壁纸生成的 Material You 配色变化。

项目提供浅色与深色两套完整主题，适用于普通 ClassicUI 候选窗以及 fcitx5-gtk 绘制的 GTK 内嵌候选窗。

## 效果展示

| 浅色模式 | 深色模式 |
|---|---|
| `[截图占位：preview/light.png]` | `[截图占位：preview/dark.png]` |

发布前请将实机截图分别保存为 `preview/light.png` 与 `preview/dark.png`，再把本表两格替换为图片。

## 特性

- `mellow-matugen` 与 `mellow-matugen-dark` 两套完整主题。
- Matugen `primary` 驱动圆角高亮背景，`on_primary` 驱动高亮文字。
- 保留 Mellow WeChat 的面板、阴影、边距与竖直候选列表布局。
- 同时支持 Nix flake 和普通 Linux 手动安装。
- 不绑定 Darkman、Waypaper 或特定桌面 shell；任何能调用 Matugen 的主题管理方案都能接入。

## 工作原理

Fcitx5 的图片型高亮不会被普通颜色字段覆盖，因此本项目同时生成：

- `highlight.svg`：使用 Matugen `primary`。
- 完整 `theme.conf`：保留布局和图片引用，并将高亮文字设为 `on_primary`。

完整配置很重要：fcitx5-gtk 只加载 XDG 搜索顺序中的第一份 `theme.conf`，不会把用户目录中的颜色片段与系统主题合并。

## 安装

### Nix flake

直接安装到用户 profile：

```bash
nix profile install github:Shangshui0302/fcitx5-matugen-theme
```

作为 flake input 接入 Home Manager：

```nix
# flake.nix
inputs.fcitx5-matugen-theme = {
  url = "github:Shangshui0302/fcitx5-matugen-theme";
  inputs.nixpkgs.follows = "nixpkgs";
};

# Home Manager 模块
home.packages = [
  inputs.fcitx5-matugen-theme.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

主题位于 profile 的 `share/fcitx5/themes/`，模板位于：

```text
~/.nix-profile/share/matugen/fcitx5-matugen-theme/
```

### 通用 Linux

```bash
git clone https://github.com/Shangshui0302/fcitx5-matugen-theme
cd fcitx5-matugen-theme

install -d ~/.local/share/fcitx5/themes ~/.config/matugen/templates/fcitx5-matugen-theme
cp -r themes/mellow-matugen themes/mellow-matugen-dark ~/.local/share/fcitx5/themes/
cp -r templates/. ~/.config/matugen/templates/fcitx5-matugen-theme/
```

## 配置 Matugen

将下面四个模板加入 Matugen 配置。路径必须换成你机器上的绝对路径：

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

Nix 安装用户可以把 `input_path` 改为 profile 中对应的模板路径。之后正常运行 Matugen，例如：

```bash
matugen image /path/to/wallpaper.png -m dark -t scheme-content --prefer saturation
```

## 配置 Fcitx5

`~/.config/fcitx5/conf/classicui.conf` 使用无 section header 的格式：

```ini
Theme=mellow-matugen-dark
DarkTheme=mellow-matugen-dark
UseDarkTheme=True
Vertical Candidate List=True
```

浅色模式把 `Theme` 改为 `mellow-matugen`，深色模式改为 `mellow-matugen-dark`。在 GTK Wayland 应用中，仅设置 `DarkTheme` 与 `UseDarkTheme` 不够，模式管理器必须同步更新 `Theme`。

主题、壁纸或模式变化后重启 Fcitx5 以清理 GTK 和 ClassicUI 缓存：

```bash
systemctl --user restart app-org.fcitx.Fcitx5@autostart.service \
  || fcitx5-remote --check -r
```

Darkman 用户可以在明暗模式 hook 中完成三件事：运行 Matugen、写入当前 `Theme`、重启 Fcitx5。本项目不保存全局深浅模式状态。

## 兼容性与限制

- 需要 Fcitx5 ClassicUI 和 Matugen。
- 深浅模式管理、壁纸选择和 Fcitx5 重启由用户现有方案负责。
- GNOME 的 Kimpanel、KDE Input Method Panel 等外部面板会自行绘制候选窗，不使用 ClassicUI 主题。
- Flatpak GTK 应用还需要能够读取用户主题目录或宿主 profile；沙箱权限不在本项目内管理。

## 许可与上游

本项目采用 [BSD 2-Clause License](LICENSE)。Mellow 的原始布局与 SVG 素材版权归 sanweiya 所有；衍生关系和来源提交见 [NOTICE](NOTICE)。

原仓库：[sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
