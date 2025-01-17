{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.programs.ccache;
in {
  options.programs.ccache = {
    enable = mkEnableOption "CCache, a compiler cache for fast recompilation of C/C++ code";
    package = mkOption {
      type = types.package;
      default = pkgs.ccache;
      description = "The CCache package to use.";
    };
    cacheDir = mkOption {
      type = types.path;
      description = "CCache directory";
      default = "/nix/var/cache/ccache";
    };
    packageNames = mkOption {
      type = types.listOf types.str;
      description = "Nix top-level packages to be compiled using CCache";
      default = [ ];
      example = [
        "wxGTK32"
        "ffmpeg"
        "libav_all"
      ];
    };
    owner = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "Owner of CCache directory";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "nixbld";
      description = "Group owner of CCache directory";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      system.activationScripts.postActivation.text = ''
        # shellcheck disable=SC2174
        mkdir -m0770 -p ${cfg.cacheDir}
        chown ${cfg.owner}:${cfg.group} ${cfg.cacheDir}
      '';

      nix.settings.extra-sandbox-paths = [ "/nix/var/cache/ccache" ];

      environment.systemPackages = [(pkgs.writeShellScriptBin "nix-ccache" ''
        echo -n "$@" | ${lib.getExe pkgs.socat} - /tmp/nix-ccache.socket
      '')];
      launchd.daemons.nix-ccache.serviceConfig = {
        ProgramArguments = let
          wrapper = pkgs.writers.writePerl "nix-ccache.pl" {} ''
            %ENV=( CCACHE_DIR => '${cfg.cacheDir}' );
            sub untaint {
              my $v = shift;
              return '-C' if $v eq '-C' || $v eq '--clear';
              return '-V' if $v eq '-V' || $v eq '--version';
              return '-s' if $v eq '-s' || $v eq '--show-stats';
              return '-z' if $v eq '-z' || $v eq '--zero-stats';
              exec('${cfg.package}/bin/ccache', '-h');
            }
            exec('${cfg.package}/bin/ccache', map { untaint $_ } split(' ', <STDIN>));
          '';
        in [
          "${lib.getExe pkgs.socat}"
          "UNIX-LISTEN:/tmp/nix-ccache.socket,unlink-early,fork,mode=0666"
          "EXEC:${wrapper}"
        ];
        GroupName = cfg.group;
        UserName = cfg.owner;
        RunAtLoad = true;
      };
    })

    (lib.mkIf (cfg.packageNames != []) {
      nixpkgs.overlays = [
        (self: super:
          lib.genAttrs cfg.packageNames (
            pn: super.${pn}.override { stdenv = builtins.trace "with ccache: ${pn}" self.ccacheStdenv; }
          ))

        (self: super: {
          ccacheWrapper = super.ccacheWrapper.override {
            extraConfig = ''
              export CCACHE_COMPRESS=1
              export CCACHE_DIR="${cfg.cacheDir}"
              export CCACHE_UMASK=007
              if [ ! -d "$CCACHE_DIR" ]; then
                echo "====="
                echo "Directory '$CCACHE_DIR' does not exist"
                echo "Please create it with:"
                echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                echo "  sudo chown ${cfg.owner}:${cfg.group} '$CCACHE_DIR'"
                echo "====="
                exit 1
              fi
              if [ ! -w "$CCACHE_DIR" ]; then
                echo "====="
                echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                echo "Please verify its access permissions"
                echo "====="
                exit 1
              fi
            '';
          };
        })
      ];
    })
  ];
}
