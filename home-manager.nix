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
  runtimeThemeNames =
    if cfg.themeSet == "light" then
      [ "mellow-matugen" ]
    else if cfg.themeSet == "dark" then
      [ "mellow-matugen-dark" ]
    else
      [ "mellow-matugen" "mellow-matugen-dark" ];
  runtimeThemeList = lib.concatStringsSep " " runtimeThemeNames;
  runtimeThemeRoot = "${config.xdg.dataHome}/fcitx5/themes";
  coreutils = pkgs.coreutils;

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

    installRuntimeThemes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install writable runtime copies of the selected themes for Matugen output.
        Runtime themes are refreshed from the selected package on every Home Manager
        activation, after which Matugen may overwrite dynamic theme files.
        Set this to false to keep the profile-only installation behavior.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ selectedPackage pkgs.matugen];

    xdg.configFile = lib.mkIf cfg.installMatugenTemplates templateFiles;

    home.activation.installFcitx5MatugenRuntimeThemes =
    lib.mkIf cfg.installRuntimeThemes (
      lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
        runtime_theme_root="${runtimeThemeRoot}"
        package_theme_root="${selectedPackage}/share/fcitx5/themes"

        ${coreutils}/bin/install -d -m 755 "$runtime_theme_root"

        # Refresh every selected runtime theme from the current package.
        for theme_name in ${runtimeThemeList}; do
          source_dir="$package_theme_root/$theme_name"
          destination_dir="$runtime_theme_root/$theme_name"

          temporary_dir="$(${coreutils}/bin/mktemp -d \
            "$runtime_theme_root/.$theme_name.XXXXXX")"

          if ! ${coreutils}/bin/cp -a "$source_dir/." "$temporary_dir/"; then
            ${coreutils}/bin/rm -rf -- "$temporary_dir"
            echo "fcitx5-matugen: failed to copy $source_dir" >&2
            exit 1
          fi

          ${coreutils}/bin/chmod -R u+rwX "$temporary_dir"

          # Replace only the runtime theme managed by this module.
          ${coreutils}/bin/rm -rf -- "$destination_dir"
          ${coreutils}/bin/mv -- "$temporary_dir" "$destination_dir"
        done

        # Remove runtime themes that are no longer selected.
        ${lib.optionalString (cfg.themeSet == "light") ''
          ${coreutils}/bin/rm -rf -- \
            "$runtime_theme_root/mellow-matugen-dark"
        ''}

        ${lib.optionalString (cfg.themeSet == "dark") ''
          ${coreutils}/bin/rm -rf -- \
            "$runtime_theme_root/mellow-matugen"
        ''}

        # Clean up the marker used by older module versions.
        ${coreutils}/bin/rm -f -- \
          "$runtime_theme_root/.fcitx5-matugen-variant"
      ''
    );
  };
}
