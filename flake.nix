{
  description = "Mellow-shaped Fcitx5 themes with Matugen runtime accent colors";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
          themeVersion = "0.2.0";
          mkThemePackage =
            {
              name,
              themes,
              blur,
            }:
            pkgs.stdenvNoCC.mkDerivation {
              pname =
                if name == "both-blur" then
                  "fcitx5-matugen-theme"
                else
                  "fcitx5-matugen-theme-${name}";
              version = themeVersion;
              src = ./.;

              installPhase = ''
                runHook preInstall

                mkdir -p \
                  "$out/share/fcitx5/themes" \
                  "$out/share/matugen/fcitx5-matugen-theme" \
                  "$out/share/licenses/fcitx5-matugen-theme" \
                  "$out/share/doc/fcitx5-matugen-theme"
                ${lib.concatMapStringsSep "\n" (theme: ''
                  cp -r "themes/${theme}" "$out/share/fcitx5/themes/"
                  cp -r "templates/${theme}" "$out/share/matugen/fcitx5-matugen-theme/"
                '') themes}

                ${lib.optionalString (!blur) ''
                  chmod -R u+w "$out/share/fcitx5/themes" "$out/share/matugen/fcitx5-matugen-theme"
                  find "$out/share/fcitx5/themes" "$out/share/matugen/fcitx5-matugen-theme" \
                    -type f \( -name 'theme.conf' -o -name 'theme.conf.tpl' \) \
                    -exec sed -i \
                      -e 's/^EnableBlur=True$/EnableBlur=False/' \
                      -e 's/^BlurMask=blur-mask.svg$/BlurMask=/' \
                      -e 's/^# 请求 Wayland compositor 原生模糊；X11 下兼容 KWin 模糊$/# 使用纯色面板，不请求 compositor 模糊/' \
                      {} +
                  find "$out/share/fcitx5/themes" -type f -name 'panel.svg' \
                    -exec sed -i 's/fill-opacity:0.25/fill-opacity:1/g' {} +
                  find "$out/share/fcitx5/themes" -type f -name 'blur-mask.svg' -delete
                ''}

                install -Dm644 LICENSE "$out/share/licenses/fcitx5-matugen-theme/LICENSE"
                install -Dm644 NOTICE "$out/share/doc/fcitx5-matugen-theme/NOTICE"

                runHook postInstall
              '';

              meta = {
                description = "Mellow-shaped Fcitx5 themes with Matugen runtime accent colors (${name})";
                homepage = "https://github.com/Shangshui0302/fcitx5-mellow-themes-matugen";
                license = pkgs.lib.licenses.bsd2;
                platforms = pkgs.lib.platforms.linux;
              };
            };

          bothBlur = mkThemePackage {
            name = "both-blur";
            themes = [ "mellow-matugen" "mellow-matugen-dark" ];
            blur = true;
          };
          lightBlur = mkThemePackage {
            name = "light-blur";
            themes = [ "mellow-matugen" ];
            blur = true;
          };
          darkBlur = mkThemePackage {
            name = "dark-blur";
            themes = [ "mellow-matugen-dark" ];
            blur = true;
          };
          bothSolid = mkThemePackage {
            name = "both-solid";
            themes = [ "mellow-matugen" "mellow-matugen-dark" ];
            blur = false;
          };
          lightSolid = mkThemePackage {
            name = "light-solid";
            themes = [ "mellow-matugen" ];
            blur = false;
          };
          darkSolid = mkThemePackage {
            name = "dark-solid";
            themes = [ "mellow-matugen-dark" ];
            blur = false;
          };
        in
        {
          default = bothBlur;
          fcitx5-matugen-theme = bothBlur;
          "both-blur" = bothBlur;
          "light-blur" = lightBlur;
          "dark-blur" = darkBlur;
          "both-solid" = bothSolid;
          "light-solid" = lightSolid;
          "dark-solid" = darkSolid;
        });

      homeManagerModules = {
        default = import ./home-manager.nix { inherit self; };
        fcitx5-matugen = import ./home-manager.nix { inherit self; };
      };

      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
          packages = self.packages.${system};
          allThemes = [ "mellow-matugen" "mellow-matugen-dark" ];
          variants = [
            {
              name = "both-blur";
              package = packages."both-blur";
              themes = allThemes;
              blur = true;
            }
            {
              name = "light-blur";
              package = packages."light-blur";
              themes = [ "mellow-matugen" ];
              blur = true;
            }
            {
              name = "dark-blur";
              package = packages."dark-blur";
              themes = [ "mellow-matugen-dark" ];
              blur = true;
            }
            {
              name = "both-solid";
              package = packages."both-solid";
              themes = allThemes;
              blur = false;
            }
            {
              name = "light-solid";
              package = packages."light-solid";
              themes = [ "mellow-matugen" ];
              blur = false;
            }
            {
              name = "dark-solid";
              package = packages."dark-solid";
              themes = [ "mellow-matugen-dark" ];
              blur = false;
            }
          ];
          renderVariantChecks = variant:
            let
              selectedThemes = lib.concatMapStringsSep "\n" (theme: ''
                test -f "${variant.package}/share/fcitx5/themes/${theme}/theme.conf"
                test -f "${variant.package}/share/fcitx5/themes/${theme}/panel.svg"
                test -f "${variant.package}/share/fcitx5/themes/${theme}/highlight.svg"
                test -f "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}/theme.conf.tpl"
                test -f "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}/highlight.svg.tpl"
              '') variant.themes;
              unselectedThemes = lib.concatMapStringsSep "\n" (theme: ''
                test ! -e "${variant.package}/share/fcitx5/themes/${theme}"
                test ! -e "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}"
              '') (lib.filter (theme: !(builtins.elem theme variant.themes)) allThemes);
              styleChecks =
                if variant.blur then
                  lib.concatMapStringsSep "\n" (theme: ''
                    grep -q '^EnableBlur=True$' "${variant.package}/share/fcitx5/themes/${theme}/theme.conf"
                    grep -q '^BlurMask=blur-mask.svg$' "${variant.package}/share/fcitx5/themes/${theme}/theme.conf"
                    grep -q 'fill-opacity:0.25' "${variant.package}/share/fcitx5/themes/${theme}/panel.svg"
                    grep -q '^EnableBlur=True$' "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}/theme.conf.tpl"
                    grep -q '^BlurMask=blur-mask.svg$' "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}/theme.conf.tpl"
                    test -f "${variant.package}/share/fcitx5/themes/${theme}/blur-mask.svg"
                  '') variant.themes
                else
                  lib.concatMapStringsSep "\n" (theme: ''
                    grep -q '^EnableBlur=False$' "${variant.package}/share/fcitx5/themes/${theme}/theme.conf"
                    grep -q '^BlurMask=$' "${variant.package}/share/fcitx5/themes/${theme}/theme.conf"
                    grep -q 'fill-opacity:1' "${variant.package}/share/fcitx5/themes/${theme}/panel.svg"
                    grep -q '^EnableBlur=False$' "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}/theme.conf.tpl"
                    grep -q '^BlurMask=$' "${variant.package}/share/matugen/fcitx5-matugen-theme/${theme}/theme.conf.tpl"
                    test ! -e "${variant.package}/share/fcitx5/themes/${theme}/blur-mask.svg"
                  '') variant.themes;
            in
            ''
              # ${variant.name}
              ${selectedThemes}
              ${unselectedThemes}
              ${styleChecks}
            '';
        in
        {
          package = packages.default;
          variants = pkgs.runCommand "fcitx5-matugen-theme-variants-check" {
            nativeBuildInputs = [ pkgs.coreutils pkgs.gnugrep ];
          } ''
            set -euo pipefail
            ${lib.concatMapStringsSep "\n" renderVariantChecks variants}
            touch "$out"
          '';
        });
    };
}
