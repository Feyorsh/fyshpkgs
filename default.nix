{ pkgs ? import <nixpkgs> { } }:
{
  #lib = import ./lib { inherit pkgs; }; # functions
  #modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  #config = pkgs.config // { allowUnfree = true; };

  Mathematica = pkgs.callPackage ./pkgs/mathematica.nix { };
  time-out-macos = pkgs.callPackage ./pkgs/time-out.nix { };
  # in nixpkgs but not built from source. Keeping for posterity
  # alt-tab-macos = pkgs.callPackage ./pkgs/alt-tab-macos.nix { };
}
