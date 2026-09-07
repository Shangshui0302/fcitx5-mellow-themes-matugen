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
        Install writable user copies of the selected themes for Matugen runtime output.
        Set this to false to keep the profile-only installation behavior.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ selectedPackage ];

    xdg.configFile = lib.mkIf cfg.installMatugenTemplates templateFiles;

    home.activation.installFcitx5MatugenRuntimeThemes =
      lib.mkIf cfg.installRuntimeThemes (
        lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
          runtime_theme_root="${runtimeThemeRoot}"
          package_theme_root="${selectedPackage}/share/fcitx5/themes"
          runtime_variant="themeSet=${cfg.themeSet};style=${cfg.style}"
          runtime_marker="$runtime_theme_root/.fcitx5-matugen-variant"
          previous_variant=""
          if [ -f "$runtime_marker" ]; then
            previous_variant="$(${coreutils}/bin/cat "$runtime_marker")"
          fi

          # An absent marker means an existing manual installation: migrate it
          # without replacing Matugen-generated theme.conf/highlight.svg files.
          refresh_managed_files=0
          if [ -n "$previous_variant" ] && [ "$previous_variant" != "$runtime_variant" ]; then
            refresh_managed_files=1
          fi

          ${coreutils}/bin/install -d -m 755 "$runtime_theme_root"
          for theme_name in ${runtimeThemeList}; do
            source_dir="$package_theme_root/$theme_name"
            destination_dir="$runtime_theme_root/$theme_name"

            if [ -L "$destination_dir" ] || [ ! -e "$destination_dir" ]; then
              temporary_dir="$(${coreutils}/bin/mktemp -d "$runtime_theme_root/.$theme_name.XXXXXX")"
              ${coreutils}/bin/cp -a "$source_dir/." "$temporary_dir/"
              ${coreutils}/bin/chmod -R u+rwX "$temporary_dir"

              # A symlink or manual copy may already contain generated colors;
              # keep them during the first migration and same-variant rebuilds.
              if [ -z "$previous_variant" ] || [ "$refresh_managed_files" -eq 0 ]; then
                for dynamic_file in theme.conf highlight.svg; do
                  if [ -f "$destination_dir/$dynamic_file" ]; then
                    ${coreutils}/bin/cp --remove-destination "$destination_dir/$dynamic_file" "$temporary_dir/$dynamic_file"
                  fi
                done
              fi

              ${coreutils}/bin/chmod -R u+rwX "$temporary_dir"
              if [ -L "$destination_dir" ]; then
                ${coreutils}/bin/rm -f "$destination_dir"
              fi
              ${coreutils}/bin/mv "$temporary_dir" "$destination_dir"
            elif [ -d "$destination_dir" ]; then
              ${coreutils}/bin/chmod -R u+rwX "$destination_dir"

              if [ "$refresh_managed_files" -eq 1 ]; then
                for managed_file in theme.conf highlight.svg panel.svg blur-mask.svg; do
                  ${coreutils}/bin/rm -f "$destination_dir/$managed_file"
                done
                ${coreutils}/bin/cp -a "$source_dir/." "$destination_dir/"
              else
                for static_file in panel.svg blur-mask.svg; do
                  if [ -e "$source_dir/$static_file" ] && [ ! -e "$destination_dir/$static_file" ]; then
                    ${coreutils}/bin/cp -p "$source_dir/$static_file" "$destination_dir/$static_file"
                  fi
                done
                for dynamic_file in theme.conf highlight.svg; do
                  if [ ! -e "$destination_dir/$dynamic_file" ]; then
                    ${coreutils}/bin/cp -p "$source_dir/$dynamic_file" "$destination_dir/$dynamic_file"
                  fi
                done
              fi

              ${coreutils}/bin/chmod -R u+rwX "$destination_dir"
            else
              echo "fcitx5-matugen: refusing to replace non-directory $destination_dir" >&2
              exit 1
            fi
          done

          marker_temporary="$(${coreutils}/bin/mktemp "$runtime_theme_root/.fcitx5-matugen-variant.XXXXXX")"
          printf '%s\n' "$runtime_variant" > "$marker_temporary"
          ${coreutils}/bin/mv -f "$marker_temporary" "$runtime_marker"
          ${coreutils}/bin/chmod u+rw "$runtime_marker"
        ''
      );
  };
}
