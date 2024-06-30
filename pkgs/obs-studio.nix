{ lib
, stdenvNoCC
, fetchurl
, undmg
}:

stdenvNoCC.mkDerivation rec {
  pname = "obs-studio";
  version = "30.2.0-rc1";

  src = fetchurl {
    url = "https://github.com/obsproject/obs-studio/releases/download/${version}/OBS-Studio-${version}-macOS-Apple.dmg";
    hash = "sha256-xEeIZYYO+iHcP52zgiSzpA93gZtDHOFR/buP1svRKJ8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free and open source software for live streaming and screen recording";
    homepage = "https://obsproject.com/";
    license = licenses.gpl2;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
  };
}
