final: prev: {
  mathematica = prev.callPackage ./mathematica.nix {};
  time-out-macos = prev.callPackage ./time-out.nix {};
  keycastr = prev.callPackage ./keycastr.nix {};
  zotero = prev.callPackage ./zotero.nix {};
  obs-studio = prev.callPackage ./obs-studio.nix {};
  # in nixpkgs but not built from source. Keeping for posterity
  # alt-tab-macos = pkgs.prev.callPackage ./alt-tab-macos.nix {};
  # inherit (prev.callPackages ./utils {}) update;
  binary-ninja = prev.callPackage ./binary-ninja {};
  binary-ninja-dev = prev.callPackage ./binary-ninja { dev = true; };
  ida-pro = prev.callPackage ./ida {
    python3 = (final.python3.override({ enableFramework = true; })).overrideAttrs(p': {
      postPatch = (p'.postPatch or "") + ''
        sed -e "s@/bin/cp@cp@g" -i $(grep -lr /bin/cp .)
        sed -e '/frameworkinstallmaclib:/a\	$(MKDIR_P) "$(DESTDIR)$(LIBPL)"' -i Makefile.pre.in
      '';
    });
  };
}
