# podman-rootless
Example of using nix + flakes to have podman rootless working

```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/6a498059fc8a120ecc2f0d8e3712f43256c4ee1d
```


```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.4 \
apk add --no-cache curl
```

```bash
podman \                               
run \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
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
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--name=fooo \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=true \
--tty=true \
--rm=false \
--userns=host \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
docker.nix-community.org/nixpkgs/nix-flakes

mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf

nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs

podman \
run \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--name=fooo \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=true \
--tty=true \
--rm=false \
--userns=host \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
docker.nix-community.org/nixpkgs/nix-flakes

nix store gc
nix \
build \
github:PedroRegisPOAR/NixOS-configuration.nix#nixosConfigurations.pedroregispoar.config.system.build.toplevel
```


### Testing it


```bash
nix \
flake \
check \
github:ES-Nix/podman-rootless/from-nixpkgs
```

```bash
nix \
run \
github:ES-Nix/podman-rootless/from-nixpkgs \
-- \
--version
```

```bash
nix \
run \
. \
-- \
--version
```

```bash
nix \
run \
. \
-- \
run \
--rm \
docker.io/library/alpine:3.14.0 \
cat /etc/os-release
```

```bash
nix \
build \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& result/bin/podman --version
```

```bash
nix \
develop \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version
```

```bash
nix \
develop \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
run \
--rm \
docker.io/library/alpine:3.14.0 \
cat /etc/os-release
```

```bash
echo 'Start kvm stuff...' \
&& getent group kvm || sudo groupadd kvm \
&& sudo usermod --append --groups kvm "$USER" \
&& echo 'End kvm stuff!' \
&& echo 'Start cgroup v2 instalation...' \
&& sudo mkdir -p /etc/systemd/system/user@.service.d \
&& sudo sh -c "echo '[Service]' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo sh -c "echo 'Delegate=yes' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo \
sed \
--in-place \
's/^GRUB_CMDLINE_LINUX="/&cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1 cgroup_no_v1=all/' \
/etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg \
&& echo 'End cgroup v2 instalation...' \
&& echo 'Start ip_forward stuff...' \
&& sudo \
sed \
-i \
'/net.ipv4.ip_forward/s/^#*//g' \
/etc/sysctl.conf \
&& echo 'End ip_forward stuff...' \
&& echo 'Start dbus stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y dbus-user-session \
&& echo 'End dbus stuff...' \
&& echo 'Start uidmap stuff...' \
&& sudo apt-get update \
&& sudo apt-get install -y uidmap \
&& echo 'End uidmap stuff...' \
&& echo 'Start bypass sudo podman stuff...' \
&& sudo \
--preserve-env \
su \
-c \
"echo \$USER ALL=\(ALL\) NOPASSWD:SETENV: >> /etc/sudoers" \
&& echo 'End bypass sudo podman stuff...' \
&& sudo reboot
```

TODO: test if it works
```bash
echo "${USER} ALL=(ALL) NOPASSWD:SETENV: ALL" | sudo tee "/etc/sudoers.d/${USER}" > /dev/null
```
Adapted from: https://askubuntu.com/a/878705

```bash
sudo apt-get update \
&& sudo apt-get install podman
```

```bash
getcap $(which newuidmap)
getcap $(which newgidmap)
```

```bash
getcap $(readlink -f $(which newuidmap))
getcap $(readlink -f $(which newgidmap))
```

```bash
stat -c %a $(readlink -f $(which newuidmap))
stat -c %a $(readlink -f $(which newgidmap))
```

```bash
getcap $(readlink -f $(which newuidmap))
getcap $(readlink -f $(which newgidmap))
```

```bash
sudo setcap 'cap_setuid=+ep' $(readlink -f $(which newuidmap))
sudo setcap 'cap_setgid=+ep' $(readlink -f $(which newgidmap))
```

```bash
sudo setcap 'cap_setuid=-ep' $(readlink -f $(which newuidmap))
sudo setcap 'cap_setgid=-ep' $(readlink -f $(which newgidmap))
```

```bash
sudo chmod -v 04755 $(readlink -f $(which newuidmap))
sudo chmod -v 04755 $(readlink -f $(which newgidmap))
```
From: https://github.com/lxc/lxc/issues/1555#issuecomment-301254419

```bash
sudo chmod -v u+s $(readlink -f $(which newuidmap))
sudo chmod -v u+s $(readlink -f $(which newgidmap))
```

```bash
sudo setcap -v 'cap_setuid+ep' $(readlink -f $(which newuidmap))
sudo setcap -v 'cap_setgid+ep' $(readlink -f $(which newgidmap))
```
```bash
sudo /nix/store/p1l48jfxcbmc68fs3wi3rm62dj4knd30-libcap-2.48/bin/setcap -v 'cap_setuid+ep' $(readlink -f $(which newuidmap))
sudo /nix/store/p1l48jfxcbmc68fs3wi3rm62dj4knd30-libcap-2.48/bin/setcap -v 'cap_setgid+ep' $(readlink -f $(which newgidmap))
```


To remove the current capabilities:
```bash
sudo setcap -r $(readlink -f $(which newuidmap))
sudo setcap -r $(readlink -f $(which newgidmap))
```


```bash
sudo apt-get purge -y podman
```

```bash
nix \
develop \
--command \
podman \
run \
--rm \
docker.io/library/alpine:3.14.0 \
cat \
/etc/os-release
```


```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix profile install nixpkgs#shadow \
&& sudo setcap 'cap_setuid=+ep' $(readlink -f $(which newuidmap)) \
&& sudo setcap 'cap_setgid=+ep' $(readlink -f $(which newgidmap)) \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.0 \
cat /etc/os-release
```


```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.0 \
cat /etc/os-release
```


```bash
nix \
profile \
install \
. \
&& nix \
develop \
. \
--command \
podman \
--version \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.0 \
apk add --no-cache curl
```