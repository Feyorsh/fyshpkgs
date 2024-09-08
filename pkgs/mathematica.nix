{ stdenv
, lib
, fetchurl
, requireFile
, makeWrapper
, perl
, undmg
}:
stdenv.mkDerivation rec {
  pname = "mathematica";
  version = "14.1";

  src = requireFile rec {
    name = "mathematica-${version}.dmg";
    url = "https://account.wolfram.com/dl/Mathematica?version=${version}&platform=Mac&includesDocumentation=false";
    sha256 = "0jg5mn9wvfxqhp3dn9kszhbl26smzscfgf98m01zzs10y22aynl8";
    message = ''
        ${name} cannot be installed automatically.
        Please go to ${url}, download and run the installer, and add the application to the store like so:

        mv W-OSX-*.dmg ${name}
        nix-prefetch-url file://\$PWD/${name}
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
    for f in $out/Applications/Wolfram.app/Contents/MacOS/**; do
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
