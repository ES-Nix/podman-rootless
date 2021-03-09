#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail



podman \
run \
--interactive \
--tty \
--workdir /code \
--volume "$(pwd)":/code \
alpine:3.13.0 \
sh -c 'id && touch my-file.txt && stat my-file.txt'

stat my-file.txt
echo

id

echo

# If it is removed with no errors the test is supposed to be ok
rm my-file.txt
