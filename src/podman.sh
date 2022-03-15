#!/usr/bin/env sh

# set -x

setcap-fix
podman-minimal-setup-registries-and-policy

podman "$@"
