#!/usr/bin/env bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail



podman \
run \
--name=service \
--rm=true \
--tty=true \
--user='root:root' \
--workdir=/code \
--volume="$(pwd)":/code \
alpine \
bash -c 'stat /app'


podman \
run \
--name=service \
--rm=true \
--tty=true \
--user='app_user:app_group' \
--workdir=/code \
--volume="$(pwd)":/code \
alpine \
bash -c 'stat media'