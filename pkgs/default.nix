final: prev: {
  mathematica = prev.callPackage ./mathematica.nix {};
  time-out-macos = prev.callPackage ./time-out.nix {};
  keycastr = prev.callPackage ./keycastr.nix {};
  zotero = prev.callPackage ./zotero.nix {};
  binary-ninja = prev.callPackage ./binary-ninja {};
  obs-studio = prev.callPackage ./obs-studio.nix {};
  # in nixpkgs but not built from source. Keeping for posterity
  # alt-tab-macos = pkgs.prev.callPackage ./alt-tab-macos.nix {};
}
