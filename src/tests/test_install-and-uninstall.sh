#!/usr/bin/env sh



ls -al /nix/store/ | grep shadow

nix profile install github:ES-Nix/podman-rootless/from-nixpkgs

ls -al /nix/store/ | grep shadow

nix profile remove '.*'


nix store gc


nix store gc --verbose \
--option keep-derivations false \
--option keep-outputs false


ls -al /nix/store/ | grep shadow

nix-collect-garbage --delete-old

