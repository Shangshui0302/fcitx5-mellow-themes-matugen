# fcitx5-mellow-themes-matugen

[English](README_EN.md) | **简体中文**

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Nix Flake](https://img.shields.io/badge/Nix-flake-5277C3.svg)](flake.nix)

变更记录见 [CHANGELOG.md](CHANGELOG.md)。

为 Fcitx5 ClassicUI 制作的 Matugen 动态重点色主题。它保留
[fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
中 Mellow WeChat 的圆角候选窗，同时让高亮背景和文字随壁纸生成的 Material You 配色变化。

项目提供浅色与深色两套完整主题，适用于普通 ClassicUI 候选窗以及 fcitx5-gtk 绘制的 GTK 内嵌候选窗。Hyprland 原生模糊已实测；niri、KWin、GNOME/Mutter 目前只保留协议层面的理论支持，欢迎提交 issue 或 PR。

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
- 使用 compositor 原生背景模糊；Hyprland 已实测，其他 compositor 的支持状态见兼容性说明。
- 同时支持 Nix flake 和普通 Linux 手动安装。
- 不绑定 Darkman、Waypaper 或特定桌面 shell；任何能调用 Matugen 的主题管理方案都能接入。

## 工作原理

Fcitx5 的图片型高亮不会被普通颜色字段覆盖，因此本项目同时生成：

- `highlight.svg`：使用 Matugen `primary`。
- `blur-mask.svg`：限定 compositor 模糊区域，保留圆角边缘。
- 完整 `theme.conf`：保留布局和图片引用，并将高亮文字设为 `on_primary`。

完整配置很重要：fcitx5-gtk 只加载 XDG 搜索顺序中的第一份 `theme.conf`，不会把用户目录中的颜色片段与系统主题合并。

## 安装

安装组合由两个选项决定：

- `themeSet`：`both`、`light` 或 `dark`；
- `style`：`blur`（当前 alpha `0.25`，请求 compositor 原生模糊）或 `solid`（不透明纯色，不请求模糊）。

默认组合是 `both-blur`。

### 普通 Linux：手动复制

普通用户不需要安装脚本，直接复制所需主题目录和 Matugen 模板即可。先在仓库根目录执行：

```bash
install -d ~/.local/share/fcitx5/themes \
  ~/.config/matugen/templates/fcitx5-matugen-theme
```

安装两种明暗模式的模糊主题：

```bash
cp -a themes/mellow-matugen themes/mellow-matugen-dark \
  ~/.local/share/fcitx5/themes/
cp -a templates/mellow-matugen templates/mellow-matugen-dark \
  ~/.config/matugen/templates/fcitx5-matugen-theme/
```

仅浅色或仅深色时，只复制对应目录：

```bash
# 仅浅色
cp -a themes/mellow-matugen ~/.local/share/fcitx5/themes/
cp -a templates/mellow-matugen ~/.config/matugen/templates/fcitx5-matugen-theme/

# 仅深色
cp -a themes/mellow-matugen-dark ~/.local/share/fcitx5/themes/
cp -a templates/mellow-matugen-dark ~/.config/matugen/templates/fcitx5-matugen-theme/
```

纯色版本可以在复制后对已选择的目录执行：

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

直接安装默认的双模式模糊主题：

```bash
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen
```

也可以选择单一模式或纯色变体：

```bash
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#light-blur
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#dark-blur
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#both-solid
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#light-solid
nix profile install github:Shangshui0302/fcitx5-mellow-themes-matugen#dark-solid
```

### Home Manager 模块

作为 flake input 接入 Home Manager：

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
  themeSet = "both"; # "light"、"dark" 或 "both"
  style = "blur";    # "solid" 或 "blur"
  installMatugenTemplates = true;
};
```

也可以直接参考 [`examples/home-manager.nix`](examples/home-manager.nix)。

模块会安装对应的主题包，并把选中的 Matugen 模板链接到：

```text
~/.config/matugen/templates/fcitx5-matugen-theme/
```

模块不会覆盖 `~/.config/fcitx5/conf/classicui.conf`，仍需保留或手动设置：

```ini
Theme=mellow-matugen
DarkTheme=mellow-matugen-dark
UseDarkTheme=True
Vertical Candidate List=True
```

若选择 `themeSet = "light"` 或 `"dark"`，请同步调整 `Theme`/`DarkTheme`，避免 Fcitx5 指向未安装的主题。

主题包的公开变体为：

```text
both-blur（default）  light-blur  dark-blur
both-solid            light-solid dark-solid
```

现有的手动 Matugen 配置也可以继续使用；不要让 HM 模块和其他模块同时写同一份 `theme.conf`。

主题位于 profile 的 `share/fcitx5/themes/`，模板位于：

```text
~/.nix-profile/share/matugen/fcitx5-matugen-theme/
```

如果不启用 `installMatugenTemplates`，可以直接引用这个 profile 路径。

## 给通用 Agent 的安装提示词

如果不熟悉 Fcitx5、Matugen 或当前桌面环境，可以把下面的提示词交给通用 Agent。它会先识别环境，再选择合适的安装方式；不要让 Agent 直接覆盖已有配置。

```text
请帮我在当前 Linux 用户环境安装并配置这个仓库：
https://github.com/Shangshui0302/fcitx5-mellow-themes-matugen

目标：让 Fcitx5 ClassicUI 候选窗和 fcitx5-gtk GTK 内嵌候选窗都使用 Mellow WeChat 风格，并让 Matugen 的 primary/on_primary 跟随壁纸更新重点背景色和文字色；保留竖直候选列表。

请按以下顺序工作：
1. 先检查发行版、是否为 NixOS、Fcitx5/Fcitx5-gtk、Matugen、当前 ClassicUI 配置、Wayland compositor、已有深浅模式管理器和 XDG data 路径。
2. 先询问或识别需要 `both`、`light` 或 `dark`，以及 `blur` 或 `solid`；NixOS 优先使用 Flake/HM 模块，其他 Linux 使用仓库中的 themes 和 templates 手动复制。不要使用 npm、pip 或 curl|sh。
3. 安装所选的完整主题目录。不要生成只有颜色字段的稀疏 theme.conf；GTK 内嵌候选窗需要完整的 Metadata、Background、Highlight、图片引用和边距。
4. 只将所选主题的 Matugen 模板接入现有配置：theme.conf 和 highlight.svg 分别写入对应用户主题目录。不要假设用户使用 Darkman、Noctalia 或 Waypaper；先复用现有模式和壁纸管理器。
5. 保留或合并现有 ~/.config/fcitx5/conf/classicui.conf 中无关设置，只确保以下键最终正确：
   Theme=mellow-matugen 或 mellow-matugen-dark（按当前模式）
   DarkTheme=mellow-matugen-dark
   UseDarkTheme=True
   Vertical Candidate List=True
6. 修改前备份已有配置；不要删除其他主题。NixOS 配置只修改仓库中的 Nix 文件，展示 diff 后等待用户自己执行 rebuild/switch。
7. 配置完成后运行一次 Matugen，重启或 reload Fcitx5，并在当前 compositor 上验证原生 Wayland ClassicUI 和 GTK 内嵌候选窗。Hyprland 是本项目已实测的 compositor；niri、KWin、GNOME/Mutter 仅记录理论支持，不要将其描述为已验证。
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

### 启用 compositor 原生模糊

主题中的 `EnableBlur=True` 会让 Fcitx5 请求 Wayland 的背景模糊协议。需要 Fcitx5 5.1.20 或更新版本；旧版仍能加载主题，但不能请求 compositor 原生模糊。

Hyprland 需要在 `decoration:blur` 中打开输入法模糊：

```ini
decoration {
  blur {
    enabled = true
    input_methods = true
    new_optimizations = true
  }
}
```

niri 理论上只需启用全局模糊参数；本项目未实测，不要用普通 `popups` 规则匹配 Fcitx5 输入法窗口：

```kdl
blur {
    passes 3
    offset 3
    noise 0.02
    saturation 1.5
}
```

KWin 理论上需要启用桌面效果中的模糊。GNOME/Mutter 理论上只有支持 `ext-background-effect` 的版本会提供 compositor 原生模糊，不支持时会平滑退化为普通主题；本项目均未实测。

当前验证状态：Hyprland 原生模糊已在本项目环境中验证。niri、KWin、GNOME/Mutter 尚未在本项目中实测，仅属于协议层面的理论支持；如果你完成了验证，欢迎提交 issue 或 PR，附上 Fcitx5、compositor 版本和截图。

## 兼容性与限制

- 需要 Fcitx5 ClassicUI 和 Matugen。
- 深浅模式管理、壁纸选择和 Fcitx5 重启由用户现有方案负责。
- Wayland 原生模糊依赖 compositor 对背景模糊协议的支持；Hyprland 需要 `input_methods=true`，且已在本项目中验证。niri、KWin、GNOME/Mutter 目前未实测，仅作理论支持。
- `fcitx5-gtk` 的 GTK3/GTK4 候选窗仍使用主题颜色和布局，但不能保证 compositor backdrop blur。
- GNOME 的 Kimpanel、KDE Input Method Panel 等外部面板会自行绘制候选窗，不使用 ClassicUI 主题。
- Flatpak GTK 应用还需要能够读取用户主题目录或宿主 profile；沙箱权限不在本项目内管理。

## 许可与上游

本项目采用 [BSD 2-Clause License](LICENSE)。Mellow 的原始布局与 SVG 素材版权归 sanweiya 所有；衍生关系和来源提交见 [NOTICE](NOTICE)。

原仓库：[sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
