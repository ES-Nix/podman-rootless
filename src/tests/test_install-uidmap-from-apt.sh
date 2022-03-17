#!/usr/bin/env sh


which newuidmap
which newgidmap

getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

stat -c %a "$(readlink -f "$(which newuidmap)")"
stat -c %a "$(readlink -f "$(which newgidmap)")"
