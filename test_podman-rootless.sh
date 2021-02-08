#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


podman \
run \
--interactive \
--rm \
--runtime $(which runc) \
--signature-policy policy.json \
--tty \
docker.io/tianon/toybox \
sh -c id


podman \
run \
--interactive \
--net=host \
--rm \
--signature-policy policy.json \
--tty \
--workdir /code \
--volume "$(pwd)":/code \
docker.io/library/alpine:3.13.0 \
sh -c 'apk add --no-cache curl && curl google.com'
