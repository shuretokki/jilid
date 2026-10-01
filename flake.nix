{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { pkgs, lib, system, ... }:
        let
          tytanic = pkgs.stdenvNoCC.mkDerivation rec {
            pname = "tytanic";
            version = "0.4.1";
            src = pkgs.fetchurl {
              url = "https://github.com/typst-community/tytanic/releases/download/v${version}/tytanic-x86_64-unknown-linux-musl.tar.xz";
              hash = "sha256-zyYiBrLIn010aQtcgl1f/OH2M+spAJSLUMwAbczr4yw=";
            };
            sourceRoot = "tytanic-x86_64-unknown-linux-musl";
            installPhase = "install -Dm755 tt $out/bin/tt";
          };
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              just
              typst
              typstyle
              tinymist
            ] ++ lib.optional (system == "x86_64-linux") tytanic;
          };
        };
    };
}
