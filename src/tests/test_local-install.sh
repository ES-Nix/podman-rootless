#!/usr/bin/env sh


nix \
profile \
install \
.#

nix run --refresh .#podman -- \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'cat /etc/os-release'

podman \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'cat /etc/os-release'

nix profile remove '.*'


/nix/store/9w5l1zrdd21hjxgjp5jnxxr6jibpjxd4-shadow-4.8.1/bin/newuidmap