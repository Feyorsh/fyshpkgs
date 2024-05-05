{ lib
, stdenvNoCC
, requireFile
, undmg
}:

stdenvNoCC.mkDerivation rec {
  pname = "nsight_compute";
  version = "2024.1.1.4-33998838";

  src = requireFile rec {
    name = "nsight-compute-mac-${version}.dmg";
    sha256 = "1yd4pqm592jjc53d2r4jbnrbamvmps8q5fhy4hgzk1zdc6ikyfml";
    message = ''
        NVIDIA Nsight Compute is proprietary software and must be acquired from NVIDIA's website.
        Please visit https://developer.nvidia.com/tools-overview/nsight-compute/get-started#macos to download the installer, and add it to the Nix store like so:

        nix-prefetch-url file://\$PWD/${name}
        rm -rf ${name}
    '';
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
    description = "An interactive profiler for CUDA and NVIDIA OptiX that provides performance metrics and API debugging.";
    homepage = "https://developer.nvidia.com/nsight-compute";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
  };
}
