{ self }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.fcitx5-matugen;
  packageSet = self.packages.${pkgs.stdenv.hostPlatform.system};
  variantName = "${cfg.themeSet}-${cfg.style}";
  selectedPackage = packageSet.${variantName};
  templateRoot = "${selectedPackage}/share/matugen/fcitx5-matugen-theme";

  templateFiles =
    (lib.optionalAttrs (cfg.themeSet != "dark") {
      "matugen/templates/fcitx5-matugen-theme/mellow-matugen/theme.conf.tpl" = {
        source = "${templateRoot}/mellow-matugen/theme.conf.tpl";
      };
      "matugen/templates/fcitx5-matugen-theme/mellow-matugen/highlight.svg.tpl" = {
        source = "${templateRoot}/mellow-matugen/highlight.svg.tpl";
      };
    })
    // (lib.optionalAttrs (cfg.themeSet != "light") {
      "matugen/templates/fcitx5-matugen-theme/mellow-matugen-dark/theme.conf.tpl" = {
        source = "${templateRoot}/mellow-matugen-dark/theme.conf.tpl";
      };
      "matugen/templates/fcitx5-matugen-theme/mellow-matugen-dark/highlight.svg.tpl" = {
        source = "${templateRoot}/mellow-matugen-dark/highlight.svg.tpl";
      };
    });
in
{
  options.programs.fcitx5-matugen = {
    enable = lib.mkEnableOption "the Fcitx5 Matugen theme package";

    themeSet = lib.mkOption {
      type = lib.types.enum [ "light" "dark" "both" ];
      default = "both";
      description = ''
        Which light/dark theme directories to install.
      '';
    };

    style = lib.mkOption {
      type = lib.types.enum [ "solid" "blur" ];
      default = "blur";
      description = ''
        Whether to install opaque solid themes or compositor-native blur themes.
        Compositor configuration remains the user's responsibility.
      '';
    };

    installMatugenTemplates = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install the selected Matugen templates under the user's XDG config directory.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ selectedPackage ];

    xdg.configFile = lib.mkIf cfg.installMatugenTemplates templateFiles;
  };
}
