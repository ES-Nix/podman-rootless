# podman-rootless
Example of using nix + flakes to have podman rootless working

```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs
```

```bash
podman \                               
run \
--device=/dev/kvm \
--interactive=true \
--privileged=true \
--tty=false \
--rm=true \
--volume '/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
echo begined
nix build github:ES-Nix/nix-qemu-kvm/dev#qemu.prepare
echo 1
timeout 60 result/runVM
echo 2
COMMANDS
```

```bash
podman \                               
run \
--device=/dev/kvm \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
--volume '/sys/fs/cgroup/':'/sys/fs/cgroup':ro \
docker.nix-community.org/nixpkgs/nix-flakes
```
