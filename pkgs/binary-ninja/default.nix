{ stdenv
, lib
, requireFile
, undmg
, makeWrapper
, writeScript
, dev ? false
}:
let
  inherit (stdenv.hostPlatform) system;

  releaseChannel = if dev then "dev" else "stable";

  srcs = let
    msg = n: ''
      Binary Ninja is proprietary software and requires a license to install.
      (Alternatively, a freeware version can be installed from https://binary.ninja/free/.)
      Visit https://binary.ninja/recover/ to receive an email with a link to an installer; then add it to the Nix store like so:

      nix-prefetch-url file://\$PWD/${n}
      rm -rf ${n}
    '';
  in lib.attrsets.recursiveUpdate rec {
    aarch64-darwin = {
      dev.src = requireFile rec {
        name = "binaryninja_personal_dev_macosx.dmg";
        message = msg name;
        sha256 = "sha256-+IzWWo4kEBN11ptPV31toHgA/vyn67yevCWVJXgEKHE=";
      };
      stable.src = requireFile rec {
        name = "binaryninja_personal_macosx.dmg";
        message = msg name;
        sha256 = "sha256-J2QGEXsOsVVRiGw17tH7FJpSxx8oaOf3OO8UBW36WCg=";
      };
    };
    x86_64-darwin = aarch64-darwin;
    aarch64-linux = {
      dev.src = requireFile rec {
        name = "binaryninja_personal_dev_linux-arm.zip";
        message = msg name;
        sha256 = "sha256-VCUuCavXB2gPVAQfyznvnzuGOC4ycW1gFFE1L9Zt/7g=";
      };
      stable.src = requireFile rec {
        name = "binaryninja_personal_linux-arm.zip";
        message = msg name;
        sha256 = "sha256-dwvp5+dvSwg6p2f48q1v3T3dviR2WKhJBaf2JUAvSb8=";
      };
    };
    x86_64-linux = {
      dev.src = requireFile rec {
        name = "binaryninja_personal_dev_linux.zip";
        message = msg name;
        sha256 = "sha256-Ad8/B4EOMVozV1qDQFSmE+HB19PDgpemqbkivI11/FA=";
      };
      stable.src = requireFile rec {
        name = "binaryninja_personal_linux.zip";
        message = msg name;
        sha256 = "sha256-UV6kosbrJzefIrnC1q/GOYon1WN20wcfc9XxkggwDFQ=";
      };
    };
  } {
    # HACK: update-source-version does a stupid grep, so `version-key` needs to match literally
    # Versions are tracked separately to avoid having to update every single platform if you don't want to
    aarch64-darwin.dev.version = "4.2.6253-dev";
    aarch64-darwin.stable.version = "4.1.5747";
    aarch64-linux.dev.version = "4.2.5777-dev";
    aarch64-linux.stable.version = "4.1.5747";
    x86_64-linux.dev.version = "4.2.5777-dev";
    x86_64-linux.stable.version = "4.1.5747";
  };

in stdenv.mkDerivation {
  pname = "binary-ninja";

  inherit (srcs.${system}.${releaseChannel}) src version;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals (stdenv.isDarwin) [ undmg ];

  sourceRoot = ".";

  installPhase = lib.strings.optionalString (stdenv.isDarwin) ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    mkdir $out/bin
    makeWrapper $out/Applications/Binary\ Ninja.app/Contents/MacOS/binaryninja $out/bin/binaryninja --inherit-argv0
    ln -s $out/bin/binaryninja $out/bin/binja

    runHook postInstall
  '';

  # If you only want to update your platform, remove "-a".
  passthru.updateScript = [ ./update.py system releaseChannel (lib.optionalString (!dev) "-a") ];

  meta = with lib; {
    description = "A modern reverse engineering platform with a scriptable and extensible decompiler.";
    homepage = "https://binary.ninja/";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    # Linux not currently supported, installPhase and buildInputs should be pretty trivial though
    platforms = lib.platforms.darwin;
  };
}
