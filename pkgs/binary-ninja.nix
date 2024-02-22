{ stdenv
, lib
, requireFile
, undmg
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "binja";
  version = "3.5";

  src = requireFile rec {
    name = "BinaryNinja-personal.dmg";
    hashMode = "recursive";
    sha256 = "1daznkcjq403jv33zr9y87c38y9xqn44x5r8ihh2vjh0z0hp66z8";
    message = ''
        Binary Ninja is proprietary software and requires a license to install.
        (Alternatively, a demo version can be installed from https://cdn.binary.ninja/installers/BinaryNinja-demo.dmg.)
        Please override this derivation with the appropriate installer file and sha256 after adding it to the Nix store like so:

        nix-store --query --hash \$(nix-store --add-fixed --recursive sha256 ${name})
        rm -rf ${name}
    '';
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals (stdenv.isDarwin) [ undmg ];

  sourceRoot = ".";

  installPhase = lib.strings.optionalString (stdenv.isDarwin) ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    mkdir $out/bin
    makeWrapper $out/Applications/Binary\ Ninja.app/Contents/MacOS/binaryninja $out/bin/binja

    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern reverse engineering platform with a scriptable and extensible decompiler.";
    homepage = "https://binary.ninja/";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = stdenv.isLinux;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
