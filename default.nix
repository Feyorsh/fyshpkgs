{ pkgs ? import <nixpkgs> { } }:
{
  #lib = import ./lib { inherit pkgs; }; # functions
  #modules = import ./modules; # NixOS modules
  #overlays = import ./overlays; # nixpkgs overlays
  #config = pkgs.config // { allowUnfree = true; };

  Mathematica = pkgs.callPackage ./pkgs/mathematica.nix { };
}
