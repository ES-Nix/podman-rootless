#!/usr/bin/env sh


echo "$(which newuidmap)"
echo "$(which newgidmap)"

getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

stat -c %a "$(readlink -f "$(which newuidmap)")"
stat -c %a "$(readlink -f "$(which newgidmap)")"
