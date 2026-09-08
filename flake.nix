{
  description = "Forus.nodes Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
      ];
      forEachSystem =
        f:
        inputs.nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.self.overlays.default
              ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: { };

      devShells = forEachSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nodejs_26
              pnpm_11

              oxlint
              tsgolint
              oxfmt

              typescript-language-server
              tailwindcss-language-server
              just
              self.formatter.${system}
            ];
          };
        }
      );
      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
