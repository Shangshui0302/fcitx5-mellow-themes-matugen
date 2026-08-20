# fcitx5-mellow-themes-matugen

[English](README_EN.md) | **简体中文**

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Nix Flake](https://img.shields.io/badge/Nix-flake-5277C3.svg)](flake.nix)

为 Fcitx5 ClassicUI 制作的 Matugen 动态重点色主题。它保留
[fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
中 Mellow WeChat 的圆角候选窗，同时让高亮背景和文字随壁纸生成的 Material You 配色变化。

项目提供浅色与深色两套完整主题，适用于普通 ClassicUI 候选窗以及 fcitx5-gtk 绘制的 GTK 内嵌候选窗。

## 效果展示

四张壁纸分别展示浅色与深色模式，共八种 Matugen 配色：

| 壁纸 | 浅色模式 | 深色模式 |
|---|---|---|
| 壁纸 1 | ![壁纸 1 浅色](preview/wallpaper-1-light.png) | ![壁纸 1 深色](preview/wallpaper-1-dark.png) |
| 壁纸 2 | ![壁纸 2 浅色](preview/wallpaper-2-light.png) | ![壁纸 2 深色](preview/wallpaper-2-dark.png) |
| 壁纸 3 | ![壁纸 3 浅色](preview/wallpaper-3-light.png) | ![壁纸 3 深色](preview/wallpaper-3-dark.png) |
| 壁纸 4 | ![壁纸 4 浅色](preview/wallpaper-4-light.png) | ![壁纸 4 深色](preview/wallpaper-4-dark.png) |

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
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen
```

作为 flake input 接入 Home Manager：

```nix
# flake.nix
inputs.fcitx5-matugen-theme = {
  url = "github:Shangshui0302/fcitx5-mellow-themes-matugen";
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
git clone https://github.com/Shangshui0302/fcitx5-mellow-themes-matugen
cd fcitx5-mellow-themes-matugen

install -d ~/.local/share/fcitx5/themes ~/.config/matugen/templates/fcitx5-matugen-theme
cp -r themes/mellow-matugen themes/mellow-matugen-dark ~/.local/share/fcitx5/themes/
cp -r templates/. ~/.config/matugen/templates/fcitx5-matugen-theme/
```

## 给通用 Agent 的安装提示词

如果不熟悉 Fcitx5、Matugen 或当前桌面环境，可以把下面的提示词交给通用 Agent。它会先识别环境，再选择合适的安装方式；不要让 Agent 直接覆盖已有配置。

```text
请帮我在当前 Linux 用户环境安装并配置这个仓库：
https://github.com/Shangshui0302/fcitx5-mellow-themes-matugen

目标：让 Fcitx5 ClassicUI 候选窗和 fcitx5-gtk GTK 内嵌候选窗都使用 Mellow WeChat 风格，并让 Matugen 的 primary/on_primary 跟随壁纸更新重点背景色和文字色；保留竖直候选列表。

请按以下顺序工作：
1. 先检查发行版、是否为 NixOS、Fcitx5/Fcitx5-gtk、Matugen、当前 ClassicUI 配置、已有深浅模式管理器和 XDG data 路径。
2. NixOS 优先使用 Nix flake/package；其他 Linux 使用仓库中的 themes 和 templates 安装到用户目录。不要使用 npm、pip 或 curl|sh。
3. 安装两套完整主题：mellow-matugen 与 mellow-matugen-dark。不要生成只有颜色字段的稀疏 theme.conf；GTK 内嵌候选窗需要完整的 Metadata、Background、Highlight、图片引用和边距。
4. 将四个 Matugen 模板接入现有 Matugen 配置：浅色/深色 theme.conf 和 highlight.svg 分别写入对应用户主题目录。不要假设用户使用 Darkman、Noctalia 或 Waypaper；先复用现有模式和壁纸管理器。
5. 保留或合并现有 ~/.config/fcitx5/conf/classicui.conf 中无关设置，只确保以下键最终正确：
   Theme=mellow-matugen 或 mellow-matugen-dark（按当前模式）
   DarkTheme=mellow-matugen-dark
   UseDarkTheme=True
   Vertical Candidate List=True
6. 修改前备份已有配置；不要删除其他主题。NixOS 配置只修改仓库中的 Nix 文件，展示 diff 后等待用户自己执行 rebuild/switch。
7. 配置完成后运行一次 Matugen，重启或 reload Fcitx5，并验证普通 ClassicUI 和 GTK 内嵌候选窗都保留圆角、图片高亮、重点色和竖直排列。
8. 最后报告：安装方式、写入的文件、模式切换命令、壁纸切换命令、验证结果，以及任何需要用户手动执行的命令。
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
