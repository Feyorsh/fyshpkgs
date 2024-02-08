{ stdenv
, lib
, fetchurl
, requireFile
, makeWrapper
, perl
}:
stdenv.mkDerivation rec {
  name = "Mathematica";
  version = "13.3.1";

  mathematica = requireFile rec {
    name     = "mathematica-${version}";
    url = "https://account.wolfram.com/dl/Mathematica?version=${version}&platform=Mac&includesDocumentation=false";
    hashMode = "recursive";
    sha256 = "0rgf80iwm7cpknx2j2x3hadihzgswn8k3igi3bsrh3jkr61c3nr1";
    message  = ''
        ${name} cannot be installed automatically (ain't Darwin fun?).
        Please go to ${url} to download the installer yourself, and install Mathematica.app.
        Then, add Mathematica to the store like so:

        mkdir -p ${name}/Applications
        mv Mathematica.app ${name}/Applications
        nix-store --add-fixed --recursive sha256 ${name}
        rm -rf ${name}
      '';
  };

  mash = fetchurl {
    url = "https://ai.eecs.umich.edu/people/dreeves/mash/mash.pl";
    sha256 = "xU1Q3TPJDsFhdGFKchHHYC6/HkV1Y4+wPqHthq3Zx4Q=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # ln behaves weirdly on Mac, and the `Mathematica` bin does not execute for some reason, so `makeWrapper` is used.
  # Also: For some reason, `makeBinaryWrapper` doesn't work, despite the fact that the main beneficiary is Darwin...
  installPhase = ''
    mkdir -p $out/bin
    for f in $mathematica/Applications/Mathematica.app/Contents/MacOS/**; do
      makeWrapper $f $out/bin/`basename $f`
    done
    cp $out/bin/MathKernel $out/bin/math
    ln -s $mathematica/Applications $out

    cp $mash $out/bin/mash
    chmod +x $out/bin/mash
    substituteInPlace $out/bin/mash --replace '  "/usr/bin/math",''\n' "" \
                                    --replace '  "/usr/local/bin/math",''\n' "" \
                                    --replace '  "/Applications/Mathematica.app/Contents/MacOS/MathKernel",''\n' "" \
                                    --replace '"/Applications/Mathematica Home Edition.app/Contents/MacOS/MathKernel",' '"'"$out"'/bin/MathKernel"'
  '';

  meta = with lib; {
    description = "Wolfram Mathematica computational software system";
    homepage = "http://www.wolfram.com/mathematica/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ herberteuler ];
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
  };
}
