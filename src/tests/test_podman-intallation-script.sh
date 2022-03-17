#!/usr/bin/env sh


which newuidmap
which newgidmap

echo
echo

./src/tests/test_install-uidmap-from-apt.sh

echo
echo

which newuidmap
which newgidmap
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

echo
echo

sudo setcap 'cap_setuid=+ep' "$(which newuidmap)"
sudo setcap 'cap_setgid=+ep' "$(which newgidmap)"

echo
echo


which newuidmap
which newgidmap
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

echo
echo


nix \
profile \
install \
--refresh \
. \
&& nix \
develop \
--refresh \
. \
--command \
podman \
--version

./src/tests/test_podman-apk-add-curl.sh


which newuidmap
which newgidmap
stat -c %a "$(readlink -f "$(which newuidmap)")"
stat -c %a "$(readlink -f "$(which newgidmap)")"
getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

