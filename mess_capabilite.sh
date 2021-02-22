#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


NEWUIDMAP=$(which newuidmap)
echo $NEWUIDMAP=$(which newuidmap)
getcap $NEWUIDMAP
echo

stat $(which newuidmap)
stat $(which newgidmap)

getcap $(which newuidmap)
getcap $(which newgidmap)

#setcap cap_setuid+ep $(which newuidmap)
#setcap cap_setuid+ep $(which newgidmap)
