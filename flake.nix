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
          package = pkgs.stdenvNoCC.mkDerivation {
            pname = "fcitx5-matugen-theme";
            version = "0.1.0";
            src = ./.;

            installPhase = ''
              runHook preInstall

              mkdir -p \
                "$out/share/fcitx5/themes" \
                "$out/share/matugen/fcitx5-matugen-theme" \
                "$out/share/licenses/fcitx5-matugen-theme" \
                "$out/share/doc/fcitx5-matugen-theme"
              cp -r themes/. "$out/share/fcitx5/themes/"
              cp -r templates/. "$out/share/matugen/fcitx5-matugen-theme/"
              install -Dm644 LICENSE "$out/share/licenses/fcitx5-matugen-theme/LICENSE"
              install -Dm644 NOTICE "$out/share/doc/fcitx5-matugen-theme/NOTICE"

              runHook postInstall
            '';

            meta = {
              description = "Mellow-shaped Fcitx5 themes with Matugen runtime accent colors";
              homepage = "https://github.com/Shangshui0302/fcitx5-mellow-themes-matugen";
              license = pkgs.lib.licenses.bsd2;
              platforms = pkgs.lib.platforms.linux;
            };
          };
        in
        {
          default = package;
          fcitx5-matugen-theme = package;
        });

      checks = forAllSystems (system: {
        package = self.packages.${system}.default;
      });
    };
}
