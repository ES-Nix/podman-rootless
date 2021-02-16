
#!/usr/bin/env bash


# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eux pipefail


#curl -fsSL https://get.docker.com | sudo sh \
#&& sudo usermod --append --groups docker "$USER" \
#&& docker --version \
#&& sudo reboot

docker pull alpine:3.13.0


podman images --quiet | xargs --no-run-if-empty podman rmi --force
podman images

docker save alpine:3.13.0 --output=oci_apine3_13_0


stat oci_apine3_13_0
# The file command may not be in the inveronment.
file oci_apine3_13_0 | grep tar


podman load < oci_apine3_13_0
podman images

nix build github:ES-Nix/poetry2nix-examples/424f84dbc089f448a7400292f78b903e44c7f074#poetry2nixOCIImage
file result
file --dereference result

podman load < result

podman images

# TODO: publish ports, test it!
podman \
run \
--interactive \
--publish=5000:5000 \
--rm \
--tty \
localhost/numtild-dockertools-poetry2nix:0.0.1 \
nixfriday

docker \
run \
--interactive \
--publish=5000:5000 \
--rm \
--tty \
numtild-dockertools-poetry2nix:0.0.1 \
nixfriday

rm --force --verbose oci_apine3_13_0

