#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


podman volume create hostvolumetest


podman \
run \
--interactive \
--name=testvolume1 \
--tty \
--workdir /code \
--volume hostvolumetest:/code \
alpine:3.13.0 \
sh -c 'id && touch my-file.txt && stat my-file.txt'

podman \
run \
--interactive \
--name=testvolume2 \
--tty \
--workdir /code \
--volume hostvolumetest:/code \
alpine:3.13.0 \
sh -c 'stat my-file.txt'


podman rm testvolume1 testvolume2
podman volume rm hostvolumetest
