#!/usr/bin/env sh


podman \
run \
--log-level=debug \
--rm=true \
docker.io/library/alpine:3.14.0 \
apk add --no-cache curl
