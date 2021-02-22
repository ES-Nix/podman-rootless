#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


# Why this changed location?
#stat ~/.config/containers/policy.json
#stat ~/.config/containers/registries.conf

stat /etc/containers/policy.json
stat /etc/containers/registries.conf
