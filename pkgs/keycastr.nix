{ lib
, stdenvNoCC
, fetchurl
, unzip
}:

stdenvNoCC.mkDerivation rec {
  pname = "keycastr";
  version = "0.9.16";

  src = fetchurl {
    url = "https://github.com/keycastr/keycastr/releases/download/v${version}/KeyCastr.app.zip";
    hash = "sha256-fKLjXinnmuYtNI/Es8dY2rd/ZdkzuO13iB+yUtamGEU=";
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
    description = "An open-source keystroke visualizer";
    homepage = "https://github.com/keycastr/keycastr";
    license = licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
  };
}
