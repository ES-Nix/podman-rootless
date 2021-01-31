# podman-rootless
Example of using nix + flakes to have podman rootless working



nix flake clone github:ES-Nix/podman-rootless --dest podman-rootless

nix develop github:ES-Nix/podman-rootless/324855d116d15a0b54f33c9489cf7c5e6d9cd714 --command ./install-podman.sh && ./test_podman-rootless.sh




IMAGE_VERSION='localhost/nix-oci-dockertools:0.0.1'

podman run \
--interactive \
--tty \
--rm \
--workdir /code \
--volume "$(pwd)":/code \
"$IMAGE_VERSION" bash -c "sudo ls -al && id"



podman ps --all --quiet | xargs --no-run-if-empty podman stop \
&& podman ps --all --quiet | xargs --no-run-if-empty podman rm --force\
&& podman images --quiet | xargs --no-run-if-empty podman rmi --force \
&& podman container prune --force \
&& podman images --quiet | podman image prune --force \
&& podman network ls --quiet | xargs --no-run-if-empty podman network rm \
&& podman volume ls --quiet | xargs --no-run-if-empty podman volume prune

   