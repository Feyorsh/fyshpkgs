{ lib
, stdenvNoCC
, fetchurl
, unzip
, makeOpenWrapper
}:

stdenvNoCC.mkDerivation rec {
  pname = "keycastr";
  version = "0.10.1";

  src = fetchurl {
    url = "https://github.com/keycastr/keycastr/releases/download/v${version}/KeyCastr.app.zip";
    hash = "sha256-Ea/QtYiM7J2Gc5T8M+WizSBrgmhJ+NW4ern2A58glUk=";
  };

  sourceRoot = ".";

  # nativeBuildInputs = [ unzip ];
  nativeBuildInputs = [ unzip makeOpenWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    openWrapper keycastr

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
