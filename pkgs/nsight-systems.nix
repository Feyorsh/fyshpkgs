{ lib
, stdenvNoCC
, requireFile
, undmg
}:

stdenvNoCC.mkDerivation rec {
  pname = "nsight_systems";
  version = "2024.2.1.106-3403790";

  src = requireFile rec {
    name = "NsightSystems-macos-public-${version}.dmg";
    sha256 = "09m12q7hyq6jphpf13p7dl6pzs4gcnjsrmnhwzpy8ag867xzgzzr";
    message = ''
        NVIDIA Nsight Systems is proprietary software and must be acquired from NVIDIA's website.
        Please visit https://developer.nvidia.com/nsight-systems/get-started#macOS to download the installer, and add it to the Nix store like so:

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
    description = "A performance analysis tool for visualizing CUDA algorithms and scaling optimization across CPUs and GPUs.";
    homepage = "https://developer.nvidia.com/nsight-systems";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
  };
}
