{ stdenv
, lib
, requireFile
, makeWrapper
, writers
, writeShellScript
, python3
, unzip
}:
let
  patcher = writers.writePython3 "patch.py" { doCheck = false; } (builtins.readFile ./patch.py);
  # IDA will crash at runtime without python configured... there is unfortunately no good way to do this at build time.
  ensureIdaPy = writeShellScript "ensure-idareg.sh" ''
    config="''${IDAUSR:=''$HOME/.idapro}"
    if [[ ! -e "$config"/ida.reg ]]; then
      echo "Creating IDA Pro config "$config"/ida.reg..."
      mkdir -p "$config"
      "$1"/idapyswitch --force-path ${lib.getLib python3}/Library/Frameworks/Python.framework/Versions/${lib.versions.majorMinor python3.version}/lib/libpython${lib.versions.majorMinor python3.version}.dylib
    fi
  '';
in
stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.0.240807";

  src = requireFile rec {
    name = "idapro_90_armmac.app.zip";
    url = "uggcf://jro.nepuvir.bet/jro/20240810212609/uggcf://bhg5.urk-enlf.pbz/orgn90_6on923/vqnceb_90_nezznp.ncc.mvc";
    sha256 = "16dgn9xviyp7vhy0j56qa232cvxgcm5y7blblibfpnnq5m7gxrz3";
    message = ''
      ${pname} cannot be installed automatically.
      Please go to ${url} and add the installer to the store like so:

      nix-prefetch-url file://\$PWD/${name}
      rm -rf ${name}
    '';
  };

  nativeBuildInputs = [ unzip makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin

    export IDADIR=$out/Applications
    export HOME=$TMPDIR

    ./Contents/MacOS/installbuilder.sh --mode unattended --prefix $IDADIR

    cd $IDADIR/*.app/Contents/MacOS

    ${patcher}
    for f in *.patched; do
      mv $f ''${f%.patched}
    done

    # internal error 30016
    rm plugins/arm_mac_user64.dylib

    for bin in ida64 idat64; do
      makeWrapper $IDADIR/*.app/Contents/MacOS/$bin $out/bin/$bin \
        --run "${ensureIdaPy} $IDADIR/*.app/Contents/MacOS"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = ''The "de-facto industry standard disassembler."'';
    homepage = "https://hex-rays.com/ida-pro/";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
  };
}
