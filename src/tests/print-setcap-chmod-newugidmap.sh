#!/usr/bin/env sh



which newuidmap
which newgidmap

getcap "$(which newuidmap)"
getcap "$(which newgidmap)"

stat -c %a "$(which newuidmap)"
stat -c %a "$(which newgidmap)"

stat -c '%U %G' "$(which newuidmap)"
stat -c '%U %G' "$(which newgidmap)"


echo '##########'


readlink -f "$(which newuidmap)"
readlink -f "$(which newgidmap)"

getcap "$(readlink -f "$(which newuidmap)")"
getcap "$(readlink -f "$(which newgidmap)")"

stat -c %a "$(readlink -f "$(which newuidmap)")"
stat -c %a "$(readlink -f "$(which newgidmap)")"

stat -c '%U %G' "$(readlink -f "$(which newuidmap)")"
stat -c '%U %G' "$(readlink -f "$(which newgidmap)")"
