#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


podman \
run \
--interactive \
--rm \
--tty \
docker.io/blang/latex \
bash -c 'pdflatex --version'
