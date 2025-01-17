{
  description = "Nix on Darwin is cursed!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" ] (system:
      let
        inherit (nixpkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay.${system} ];
          config = {
            allowUnfree = true;
          };
        };
      in {
        overlay = import ./pkgs;

        legacyPackages = pkgs;

        devShells.default = with pkgs; mkShell {
          packages = [
            hello
          ];
        };
      }) // {
        darwinModules = import ./modules;
      };
}
