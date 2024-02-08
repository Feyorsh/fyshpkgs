{ lib
, stdenv
, fetchFromGitHub
, AppKit
, CoreAudio
, CoreWLAN
, CoreVideo
, DisplayServices
, IOKit
, MediaRemote
, SkyLight
, testers
}:

let
  inherit (stdenv.hostPlatform) system;
  target = {
    "aarch64-darwin" = "arm64";
    "x86_64-darwin" = "x86";
  }.${system} or (throw "Unsupported system: ${system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "AltTab";
  version = "6.63.0";

  src = fetchFromGitHub {
    owner = "lwouis";
    repo = "alt-tab-macos";
    rev = "v${finalAttrs.version}";
    sha256 = "FntWC180wpUyxP5iYdo/p2LbP0dbv1y6CXersfBT5b4=";
  };

  buildInputs = [
    AppKit
    CoreAudio
    CoreWLAN
    CoreVideo
    DisplayServices
    IOKit
    MediaRemote
    SkyLight
  ];

  makeFlags = [
    target
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./bin/sketchybar $out/bin/sketchybar

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    version = "sketchybar-v${finalAttrs.version}";
  };

  meta = {
    description = "Windows alt-tab on macOS";
    homepage = "https://alt-tab-macos.netlify.app/";
    license = lib.licenses.gpl3;
    #mainProgram = "sketchybar";
    #maintainers = with lib.maintainers; [ shorden ];
    platforms = lib.platforms.darwin;
  };
})
