#!/usr/bin/env sh


echo "$(which newuidmap)"
echo "$(which newgidmap)"
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

sudo apt-get remove -y uidmap \
&& sudo apt-get purge -y uidmap


#nix store gc --verbose
#nix store optimise --verbose

echo "$(which newuidmap)"
echo "$(which newgidmap)"
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"
