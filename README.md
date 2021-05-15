# podman-rootless
Example of using nix + flakes to have podman rootless working



nix flake clone github:ES-Nix/podman-rootless --dest podman-rootless

nix develop github:ES-Nix/podman-rootless/324855d116d15a0b54f33c9489cf7c5e6d9cd714 --command ./install-podman.sh && ./test_podman-rootless.sh

nix develop github:ES-Nix/podman-rootless/bffe8ae0d5b933b321e9fc0de25d992f5f5540d0

```
nix \
develop \
github:ES-Nix/podman-rootless/706380778786b88d4886a2c43e1924e200cb5023 \
--command \
podman \
run \
-it \
alpine:3.13.0 \
sh \
-c 'uname --all'
```


nix \
build \
github:ES-Nix/podman-rootless/composable-flake#podman


## Install via git

```
git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless
git checkout bffe8ae0d5b933b321e9fc0de25d992f5f5540d0
nix develop
```



IMAGE_VERSION='localhost/nix-oci-dockertools:0.0.1'

podman run \
--interactive \
--tty \
--rm \
--workdir /code \
--volume "$(pwd)":/code \
"$IMAGE_VERSION" bash -c "sudo ls -al && id"
   