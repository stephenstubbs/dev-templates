{
  description = "A Nix-flake-based Java development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      javaVersion = 22; # Change this value to update the whole stack

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      overlays.default = final: prev: rec {
        jdk = prev."jdk${toString javaVersion}";
        maven = prev.maven.override { jre = jdk; };
        gradle = prev.gradle.override { java = jdk; };
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              maven
              gradle
              gcc
              ncurses
              patchelf
              zlib
            ];
          };
        }
      );
    };
}
