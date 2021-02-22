#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


# This image is > 850MB
podman \
run \
--interactive \
--network host \
--rm \
--tty \
python:3.9 \
bash -c 'python --version'

# This image is > 2.5Gbytes
podman \
run \
--interactive \
--network host \
--rm \
--tty \
jupyter/scipy-notebook \
bash -c 'python --version'

# This image is > 4Gbytes
podman \
run \
--interactive \
--network host \
--rm \
--tty \
jupyter/datascience-notebook:r-4.0.3 \
bash -c 'python --version'

# This image is > 4Gbytes
podman \
run \
--interactive \
--network host \
--rm \
--tty \
blang/latex \
bash -c 'pdflatex --version'
