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

result/bin/podman \
run \
--interactive=true \
--tty=true \
alpine:3.13.0 \
sh \
-c 'uname --all && apk add --no-cache python3 && python --version'
```

## Install via git

```
git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless
git checkout bffe8ae0d5b933b321e9fc0de25d992f5f5540d0
nix develop
```


## From nixpkgs with flakes: podman rootless


```bash
mkdir -p "$HOME"/.config/containers
cat << 'EOF' >> "$HOME"/.config/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}
EOF

mkdir -p "$HOME"/.config/containers
cat << 'EOF' >> "$HOME"/.config/containers/registries.conf
[registries.search]
registries = ['docker.io']
[registries.block]
registries = []
EOF
```


```bash
nix \
shell \
nixpkgs/84aa23742f6c72501f9cc209f29c438766f5352d#podman \
--command \
podman \
run \
--interactive=true \
--tty=true \
alpine:3.13.0 \
sh \
-c 'uname --all && apk add --no-cache python3 && python --version'
```


### Nesting podman inside podman

It was tested using `nix` statically built, it worked!

```bash
nix \
shell \
nixpkgs/84aa23742f6c72501f9cc209f29c438766f5352d#podman \
--command \
podman \
run \
--privileged=true \
--device=/dev/fuse \
--device=/dev/kvm \
--env=DISPLAY=':0.0' \
--interactive=true \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--tty=true \
--rm=true \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
docker.nix-community.org/nixpkgs/nix-flakes
```

```bash
mkdir -p "$HOME"/.config/containers
cat << 'EOF' >> "$HOME"/.config/containers/registries.conf
[registries.search]
registries = ['docker.io']
[registries.block]
registries = []
EOF

mkdir /var/tmp
mkdir -p /etc/containers
cat << 'EOF' >> /etc/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}
EOF
```

```bash
nix \
shell \
nixpkgs/84aa23742f6c72501f9cc209f29c438766f5352d#podman \
--command \
podman \
run \
--cap-add=SYS_ADMIN \
--device=/dev/fuse \
--env=DISPLAY=':0.0' \
--interactive=true \
--log-level=debug \
--mount=type=tmpfs,destination=/var/lib/containers \
--network=host \
--tty=false \
--rm=true \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
alpine:3.13.0 \
sh \
<< COMMANDS
uname --all
apk add --no-cache python3
python3 --version
COMMANDS
```

```bash
podman \
run \
--net=host \
--interactive=true \ 
--log-level=debug \
--tty=true \
k8s.gcr.io/busybox \
sh
```

In an debian like OCI image `apt-get update && apt-get install -y podman uidmap runc ca-certificates cni`


Refs:
- [Nested podman ignores error when mounting container root file system and requires --security-opt=seccomp=unconfined in addition to --privileged.](https://github.com/containers/podman/issues/8849)
- [How to run podman from inside a container?](https://stackoverflow.com/a/56856410)
- https://stackoverflow.com/questions/56032747/how-to-run-podman-from-inside-a-container/56856410#comment106148996_56033450
- https://github.com/containers/podman/issues/4056#issuecomment-613291299
- https://indico.cern.ch/event/757415/contributions/3421994/attachments/1855302/3047064/Podman_Rootless_Containers.pdf
- [Kubernetes On Cgroup v2 - Giuseppe Scrivano, Red Hat](https://www.youtube.com/watch?v=u8h0e84HxcE)
- https://github.com/containers/podman/issues/6053#issuecomment-624056425
- [Using volumes with rootless podman, explained ](https://www.tutorialworks.com/podman-rootless-volumes/)
