{ pkgs ? import <nixpkgs> { } }:
with pkgs; {
  #lib = import ./lib { inherit pkgs; }; # functions
  #modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  #config = config // { allowUnfree = true; };

  mathematica = callPackage ./pkgs/mathematica.nix { };
  time-out-macos = callPackage ./pkgs/time-out.nix { };
  keycastr = callPackage ./pkgs/keycastr.nix { };
  zotero = callPackage ./pkgs/zotero.nix { };
  binja = callPackage ./pkgs/binary-ninja.nix { };
  cudaPackages = {
    nsight_systems = callPackage ./pkgs/nsight-systems.nix { };
    nsight_compute = callPackage ./pkgs/nsight-compute.nix { };
  };
  # in nixpkgs but not built from source. Keeping for posterity
  # alt-tab-macos = pkgs.callPackage ./pkgs/alt-tab-macos.nix { };
}
