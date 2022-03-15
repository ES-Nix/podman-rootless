#!/usr/bin/env sh


sudo setcap 'cap_setuid=+ep' "$(which newuidmap)"
sudo setcap 'cap_setgid=+ep' "$(which newgidmap)"

sudo chown "$(id -u)":"$(id -g)" "$(readlink -f "$(which newuidmap)")"
sudo chown "$(id -u)":"$(id -g)" "$(readlink -f "$(which newgidmap)")"

sudo chmod -v 4755 "$(readlink -f "$(which newuidmap)")"
sudo chmod -v 4755 "$(readlink -f "$(which newgidmap)")"
