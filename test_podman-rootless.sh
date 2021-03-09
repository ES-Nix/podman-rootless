#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


podman \
run \
--interactive=true \
--network host \
--rm=true \
--tty=true \
tianon/toybox \
sh -c id


podman \
run \
--interactive \
--network host \
--rm=true \
--tty=true \
busybox:1.32.1-musl \
sh -c id


podman \
run \
--interactive=true \
--network host \
--tty=true \
--workdir /code \
--volume "$(pwd)":/code \
alpine:3.13.0 \
sh -c 'id'


podman \
run \
--interactive \
--network host \
--rm=true \
--tty \
--user=nobody \
ubuntu:20.04 \
bash -c 'id'


podman \
run \
--interactive \
--network host \
--rm=true \
--tty=true \
--user=nobody \
--workdir /code \
--volume "$(pwd)":/code \
alpine:3.13.0 \
sh -c 'id'


podman \
run \
--interactive \
--network host \
--rm=true \
--tty=true \
ubuntu:20.04 \
bash -c 'apt update && apt install -y curl'


podman \
run \
--interactive \
--network host \
--rm=true \
--tty=true \
--workdir /code \
--volume "$(pwd)":/code \
alpine:3.13.0 \
sh -c 'apk add --no-cache curl && curl google.com'


# From: https://github.com/containernetworking/cni/issues/770#issuecomment-641532110

podman \
run \
--interactive=true \
--network=host \
--tty=true \
alpine:3.13.0 \
sh -c 'ip addr show'