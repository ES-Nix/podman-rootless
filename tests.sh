#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


./test_configs.sh
./test_exclude_loaded_image.sh
./test_podman-rootless.sh
