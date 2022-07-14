# podman-rootless
Example of using nix + flakes to have podman rootless working


```bash
nix \
profile \
install \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs#podman
```

```bash
nix \
profile \
install \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs#podman-unwrapped
```


```bash
nix \
profile \
install \
--refresh \
.#
```

```bash
podman \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'
cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version
'
```


```bash
nix \
run \
github:ES-Nix/podman-rootless/from-nixpkgs \
-- \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'
cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version
'
```

```bash
nix \
run \
.# \
-- \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'
cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version
'
```




```bash
nix \
shell \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
sh \
-c \
"
  podman --version \
  && podman \
  run \
  --rm=true \
  docker.io/library/alpine:3.14.2 \
  sh \
  -c \
  '
    cat /etc/os-release \
    && apk update \
    && apk add --no-cache python3 \
    && python3 --version
  '
"
```

### Updating podman

```bash
nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/nixpkgs-unstable
```


```bash
nix \
run \
.# \
-- \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
"cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version"
```



```bash
nix \
flake \
check \
github:ES-Nix/podman-rootless/from-nixpkgs
```


```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix flake check --impure .#
```

```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/6a498059fc8a120ecc2f0d8e3712f43256c4ee1d
```

```bash
nix profile remove '.*' \
&& nix store gc \
&& nix profile install .#podman \
&& podman \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
"cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version"
```


### 

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
mkdir --parent --mode=0755 ~/.config/nix
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


### Testing the podman-unwrapped


```bash
nix \
profile \
install \
nixpkgs#podman-unwrapped \
nixpkgs#conmon \
nixpkgs#runc \
nixpkgs#slirp4netns \
&& nix run github:ES-Nix/podman-rootless/from-nixpkgs#podman-minimal-setup-registries-and-policy

podman-unwrapped \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
"cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version"

#mkdir -p ~/.config/containers
#cat << 'EOF' >> ~/.config/containers/policy.json
#{
#    "default": [
#        {
#            "type": "insecureAcceptAnything"
#        }
#    ],
#    "transports":
#        {
#            "docker-daemon":
#                {
#                    "": [{"type":"insecureAcceptAnything"}]
#                }
#        }
#}
#EOF
#
#mkdir -p ~/.config/containers
#cat << 'EOF' >> ~/.config/containers/registries.conf
#[registries.search]
#registries = ['docker.io']
#[registries.block]
#registries = []
#EOF
```



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
--rm=true \
--userns=host \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
docker.nix-community.org/nixpkgs/nix-flakes


### Testing it

#### Using a QEMU + KVM VM with an ubuntu cloud image and with a volume 

```bash
rm -fv result *.qcow2*; \
nix store gc --verbose \
&& nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev \
--command bash -c 'vm-kill; run-vm-kvm && prepares-volume && ssh-vm'
```


```bash
vm-kill; reset-to-backup && ssh-vm
```


### 

```bash
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs
```


```bash
podman \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
"cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version"
```

```bash
nix \
run \
github:ES-Nix/podman-rootless/from-nixpkgs \
-- \
run \
--rm=true \
docker.io/library/alpine:3.14.2 \
sh \
-c \
"cat /etc/os-release \
&& apk update \
&& apk add --no-cache python3 \
&& python3 --version"
```

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
github:ES-Nix/podman-rootless/from-nixpkgs \
-- \
run \
--rm \
docker.io/library/alpine:3.14.2 \
cat /etc/os-release
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
docker.io/library/alpine:3.14.2 \
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
profile \
install \
.# \
&& nix \
develop \
.# \
--command \
podman \
--version \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'apk add --no-cache curl'
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
docker.io/library/alpine:3.14.2 \
cat /etc/os-release
```

```bash
echo 'Start kvm stuff...' \
&& getent group kvm || sudo groupadd kvm \
&& sudo usermod --append --groups kvm "$USER" \
&& echo 'End kvm stuff!' \
&& echo 'Start cgroup v2 installation...' \
&& sudo mkdir -p /etc/systemd/system/user@.service.d \
&& sudo sh -c "echo '[Service]' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo sh -c "echo 'Delegate=yes' >> /etc/systemd/system/user@.service.d/delegate.conf" \
&& sudo \
sed \
--in-place \
's/^GRUB_CMDLINE_LINUX="/&cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1 cgroup_no_v1=all/' \
/etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg \
&& echo 'End cgroup v2 installation...' \
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


#### Installing podman from apt

```bash
sudo apt-get update \
&& sudo apt-get install -y podman
```

```bash
getcap $(which newuidmap)
getcap $(which newgidmap)
```

####

#### 

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends --no-install-suggests uidmap
```

```bash
getcap $(which newuidmap)
getcap $(which newgidmap)
```

```bash
sudo setcap 'cap_setuid=+ep' $(which newuidmap)
sudo setcap 'cap_setgid=+ep' $(which newgidmap)
```

```bash
getcap $(which newuidmap)
getcap $(which newgidmap)
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
docker.io/library/alpine:3.14.2 \
apk add --no-cache curl
```

```bash
nix profile remove "$(nix eval --raw nixpkgs#shadow)"
```

```bash
sudo apt-get remove -y uidmap \
&& sudo apt-get purge -y uidmap
```

####

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
docker.io/library/alpine:3.14.2 \
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
docker.io/library/alpine:3.14.2 \
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
docker.io/library/alpine:3.14.2 \
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
docker.io/library/alpine:3.14.2 \
apk add --no-cache curl
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
docker.io/library/alpine:3.14.2 \
apk add --no-cache curl
```



sudo cp "$(readlink -f "$(which newuidmap)")" /usr/bin
sudo cp "$(readlink -f "$(which newgidmap)")" /usr/bin



```bash
nix \
profile \
install \
.# \
&& nix \
develop \
.# \
--command \
podman \
--version \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'apk add --no-cache curl'
```

```bash
nix profile remove '.*'
nix store gc --verbose
```

```bash
nix \
profile \
install \
.# \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'apk add --no-cache curl'
```


```bash
podman \
run \
--device=/dev/kvm \
--device=/dev/fuse \
--log-level=error \
--env STORAGE_DRIVER=vfs \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--group-add=keep-groups \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
--security-opt seccomp=unconfined \
--security-opt label=disable \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
--volume=/sys/fs/cgroup/:/sys/fs/cgroup:ro \
--volume=/var/run/docker.sock:/var/run/docker.sock:ro \
--volume=/lib/modules:/lib/modules:ro \
--volume=/boot:/boot:ro \
--volume=/proc/:/proc/:ro \
--volume="$(echo ~)"/.ssh:/root/.ssh:ro \
--volume="$(pwd)":/code:rw \
--workdir=/code \
docker.io/nixpkgs/nix-flakes
```


```bash
sudo apt-get purge -y uidmap
sudo apt-get autoremove -y
```


###  


```bash
podman \
run \
--group-add=keep-groups \
docker.io/library/alpine:latest \
sh \
-c \
'touch foo-bar'
```

```bash
podman \
run \
--group-add=keep-groups \ 
--user="$(cat /etc/subuid | cut -d':' -f3)" ubuntu sh -c 'groups'
```

### Nesting PinP


https://www.redhat.com/sysadmin/podman-inside-container


```bash
podman \
run \
--interactive=true \
--privileged=false \
--tty=true \
--rm=true \
--user=podman \
--device=/dev/fuse \
quay.io/podman/stable \
    podman \
    --version
```



```bash
podman \
run \
--interactive=true \
--privileged=false \
--tty=true \
--rm=true \
--user=podman \
--device=/dev/fuse \
quay.io/podman/stable \
    podman \
    run \
    --interactive=true \
    --privileged=false \
    --tty=true \
    --rm=true \
    docker.io/library/alpine:latest \
    sh \
    -c \
    "echo && cat /etc/os-release"
```

```bash
podman \
run \
--interactive=true \
--privileged=false \
--tty=true \
--rm=true \
--user=podman \
--device=/dev/fuse \
quay.io/podman/stable \
    podman \
    run \
    --interactive=true \
    --privileged=false \
    --tty=true \
    --rm=true \
    docker.io/library/ubuntu:latest \
    bash \
    -c \
    "echo && cat /etc/os-release"
```



### PinPinP


```bash
podman \
run \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--events-backend=file \
--device=/dev/kvm \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=true \
--tty=false \
--rm=true \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS
mkdir --parent --mode=755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-derivations' >> ~/.config/nix/nix.conf

nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& mkdir -p -m 0755 /var/tmp \
&& podman \
run \
--cgroups=disabled \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--events-backend=file \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--network=host \
--privileged=true \
--tty=false \
--rm=true \
--user=0 \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDSNESTED
mkdir --parent --mode=0755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-derivations' >> ~/.config/nix/nix.conf
nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& mkdir --parent --mode=0755 /var/tmp \
&& podman \
run \
--events-backend=file \
--storage-driver="vfs" \
--cgroups=disabled \
--log-level=error \
--interactive=true \
--network=host \
--tty=true \
docker.io/library/alpine:3.14.0 \
sh \
-c 'apk add --no-cache curl && echo PinPinP'
COMMANDSNESTED
COMMANDS
```

TODO:
--volume=/etc/localtime:/etc/localtime:ro \


