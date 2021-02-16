
#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail

stat ~/.config/containers/policy.json
stat ~/.config/containers/registries.conf
