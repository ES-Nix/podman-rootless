#!/usr/bin/env sh

# set -x

setcap-fix-unwrapped
podman-minimal-setup-registries-and-policy

podman "$@"
