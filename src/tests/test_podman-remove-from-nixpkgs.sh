#!/usr/bin/env sh


which newuidmap
which newgidmap
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

nix profile remove "$(nix eval --raw nixpkgs#shadow)"
nix profile remove "$(nix eval --raw .#)"

#nix store gc --verbose
#nix store optimise --verbose

which newuidmap
which newgidmap
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"
