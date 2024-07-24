#!/usr/bin/env python3

import argparse
import json
import os
import subprocess

def main(args):
    path = os.getcwd()

    if args.nixpkgs:
        nixpkgs = args.nixpkgs
    else:
        nixpkgs = json.loads(subprocess.check_output(['nix', 'eval', '-f', path, 'inputs.nixpkgs.outPath', '--json']).decode('utf-8'))

    update_nix = os.path.join(nixpkgs, 'maintainers/scripts/update.nix')

    nix_args = [update_nix]
    if args.system:
        sys = args.system
        nix_args += ['--argstr', 'system', sys]
    else:
        sys = "aarch64-darwin"
    nix_args += ['--arg', 'include-overlays', f'(import {path} {{ }}).outputs.legacyPackages.{sys}.overlays']
    nix_args += ['--argstr', 'path', args.attr_path]
    if args.commit:
        nix_args += ['--argstr', 'commit', 'true']

    print(nix_args)
    nix_shell = ['nix-shell'] + nix_args

    os.execvp(nix_shell[0], nix_shell)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Rebuild system')
    parser.add_argument('--commit', help='Commit the changes', action='store_true')
    parser.add_argument('--nixpkgs', dest='nixpkgs', help='Override the nixpkgs flake input with this path, it will be used fir finding update.nix', nargs='?')
    parser.add_argument('--system', metavar='system', help='Explicitly set system')
    parser.add_argument('attr_path', metavar='attr-path', help='Attribute path of package to update')

    args = parser.parse_args()
    main(args)
