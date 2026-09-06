{ inputs, ... }:

{
  imports = [
    inputs.fcitx5-matugen-theme.homeManagerModules.default
  ];

  programs.fcitx5-matugen = {
    enable = true;
    themeSet = "both";
    style = "blur";
    installMatugenTemplates = true;
  };
}
