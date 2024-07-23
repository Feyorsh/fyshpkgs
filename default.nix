# A function so that this can be imported like nixpkgs by various update scripts and nixpkgs-hammering.
{ }:
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake-compat = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
  self = import flake-compat {
    src =  ./.;
  };
  packages = self.defaultNix.outputs.legacyPackages.${builtins.currentSystem};
in
packages
// self.defaultNix
