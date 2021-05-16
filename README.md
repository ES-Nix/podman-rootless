# podman-rootless

Example of using nix + flakes to have podman rootless working.



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

```bash
nix \
develop \
github:ES-Nix/podman-rootless/feature/composable-flake \
--command \
podman \
run \
--interactive=true \
--tty=true \
alpine:3.13.0 \
sh \
-c 'uname --all && apk add --no-cache git && git init'
```


```bash
nix \
build \
github:ES-Nix/podman-rootless/feature/composable-flake#podman

result/bin/podman run \
--interactive=true \
--tty=true \
alpine:3.13.0 \
sh \
-c 'uname --all && apk add --no-cache git && git init'
```

## Install via git

```
git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless
git checkout bffe8ae0d5b933b321e9fc0de25d992f5f5540d0
nix develop
```
