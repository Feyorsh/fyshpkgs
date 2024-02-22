{ stdenv
, lib
, fetchurl
, requireFile
, makeWrapper
, perl
, undmg
}:
stdenv.mkDerivation rec {
  name = "Mathematica";
  version = "14.0";

  src = requireFile rec {
    name = "mathematica-${version}.dmg";
    url = "https://account.wolfram.com/dl/Mathematica?version=${version}&platform=Mac&includesDocumentation=false";
    hashMode = "recursive";
    sha256 = "07rmvrx57kf0hmki5bj2pj40w5g8lnjigpdp1z3xlfgyva27hraz";
    message = ''
        ${name} cannot be installed automatically.
        Please go to ${url} to download the installer yourself, and add it to the store like so:

        mv M-OSX-*.dmg ${name}
        nix-store --query --hash \$(nix-store --add-fixed --recursive sha256 ${name})
        rm -rf ${name}
    '';
  };

  mash = fetchurl {
    url = "https://ai.eecs.umich.edu/people/dreeves/mash/mash.pl";
    sha256 = "xU1Q3TPJDsFhdGFKchHHYC6/HkV1Y4+wPqHthq3Zx4Q=";
  };

  nativeBuildInputs = [ makeWrapper undmg ];
  buildInputs = [ perl ];

  sourceRoot = ".";

  # makeBianryWrapper supposedly doesn't work. idk man
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications


    mkdir -p $out/bin
    for f in $out/Applications/Mathematica.app/Contents/MacOS/**; do
      makeWrapper $f $out/bin/`basename $f`
    done
    cp $out/bin/MathKernel $out/bin/math

    cp $mash $out/bin/mash
    chmod +x $out/bin/mash
    substituteInPlace $out/bin/mash --replace '  "/usr/bin/math",''\n' "" \
                                    --replace '  "/usr/local/bin/math",''\n' "" \
                                    --replace '  "/Applications/Mathematica.app/Contents/MacOS/MathKernel",''\n' "" \
                                    --replace '"/Applications/Mathematica Home Edition.app/Contents/MacOS/MathKernel",' '"'"$out"'/bin/MathKernel"'

    runHook postInstall
  '';

  meta = with lib; {
    description = "Wolfram Mathematica computational software system";
    homepage = "http://www.wolfram.com/mathematica/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
  };
}
