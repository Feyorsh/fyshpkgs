{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "time-out";
  version = "2.9.2";

  src = fetchurl {
    #inherit version;
    url = "https://www.dejal.com/download/?prod=timeout&vers=${version}&lang=en&op=getnow&ref=timeout";
    hash = "sha256-ZIVM9uXJFnKR1rV2+b+XV4FbGSuMQL0kOjRS8jSQx3Q=";
    name = "timeout-${version}.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  meta = with lib; {
    description = "A utility to gently remind you to take a break on a regular basis.";
    homepage = "https://www.dejal.com/timeout";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    #maintainers = with maintainers; [ shorden ];
    platforms = platforms.darwin;
  };
}
