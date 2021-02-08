#!/usr/bin/env bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail


NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

sudo setcap cap_setuid+ep "$NEWUIDMAP"
sudo setcap cap_setgid+ep "$NEWGIDMAP"

sudo chmod -s "$NEWUIDMAP"
sudo chmod -s "$NEWGIDMAP"


cat << EOF > policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}
EOF
