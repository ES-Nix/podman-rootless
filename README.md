# podman-rootless
Example of using nix + flakes to have podman rootless working



nix flake clone github:ES-Nix/podman-rootless --dest podman-rootless

nix develop github:ES-Nix/podman-rootless/324855d116d15a0b54f33c9489cf7c5e6d9cd714 --command ./install-podman.sh && ./test_podman-rootless.sh

nix develop github:ES-Nix/podman-rootless/bffe8ae0d5b933b321e9fc0de25d992f5f5540d0


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
--rm=true \
--tty=true \
--workdir /code \
--volume "$(pwd)":/code \
"$IMAGE_VERSION" bash -c "sudo ls -al && id"
 

Other somehow hard tests:

```
podman \
run \
--interactive \
--rm=true \
--tty=true \
python:3.8 \
bash
```

```  
podman \
run \
--interactive \
--rm=true \
--tty=true \
blang/latex \
bash
```

```  
podman \
run \
--interactive \
--rm=true \
--tty=true \
wernight/funbox \
nyancat
```


## Notes

The behavior "the nix develop command which uses the devShell.${system} 
flake output if it exists or defaultPackage.${system} otherwise.", [source](https://github.com/NixOS/nix/issues/2854#issuecomment-673923349), 
is really important to understand the current working state.

[Additional groups in buildFHSUserEnv](https://nix-dev.science.uu.narkive.com/18BjYWWc/additional-groups-in-buildfhsuserenv) TL;DR it looks like (i am not sure) it is not possible.

## 



```
nix build \
&& result/fsh-podman-rootless-env podman --help
```

### Troubleshooting

```
stat $(which newuidmap)
stat $(which newgidmap)
```

cat /proc/self/uid_map
podman unshare cat /proc/self/uid_map

whereis newuidmap 
whereis newgidmap


ls "$HOME"/.config/containers
ls "$HOME"/.local/share/containers

ls ~/.config/containers
ls ~/.local/share/containers

rm -rf ~/.config/containers ~/.local/share/containers

Use the `--log-level=debug`, really usefull!


podman unshare cat /proc/self/uid_map [from](https://github.com/containers/podman/issues/3890#issuecomment-525275812)
Meaning of this in https://github.com/containers/podman/issues/3890#issuecomment-525276385

filecap /usr/bin/newuidmap
filecap $(which newuidmap) TODO: not tested

`ls -l /usr/bin/new{uid,gid}*`


TODO: reproduce it using QEMU?
https://github.com/containers/podman/issues/3890#issuecomment-525298907
https://github.com/containers/podman/issues/3890#issuecomment-525331569


```
UID_INSIDE=$(podman run --name UID_probe --rm foo-image /usr/bin/id -u)
podman unshare chown -R $UID_INSIDE volumes

podman run --pod foo-pod --name foo\
 --rm\
 -v $VOLUMES/data:$CONTAINER/data\
 foo-image
```
https://github.com/containers/podman/issues/7778#issuecomment-698845316


TODO: important!
https://github.com/NixOS/nixpkgs/issues/112902

About the `profile` in the [buildFHSUserEnv](https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments), [gsc.io sec-fhs-environments](https://gsc.io/70266391-48a6-49be-ab5d-acb5d7f17e76-nixpkgs/doc/nixpkgs-manual/html/sec-fhs-environments.html)
https://github.com/NixOS/nixpkgs/pull/80457/files#diff-aff959a600d3441934b3b905339c0f90dcd8122e8774ee2dbcae35d72f349991R152

IHaskell + jupyter + notebook + buildFHSUserEnv
https://vaibhavsagar.com/blog/2018/03/17/faking-non-nixos-stack/

I've downloaded a binary, but I can't run it, what can I do? buildFHSUserEnv
https://nixos.wiki/wiki/FAQ#How_can_I_manage_software_with_nix-env_like_with_configuration.nix.3F

TODO: what is this?
https://discourse.nixos.org/t/setting-run-user-with-oci-containers-and-systemd/9900/8

### Faced a annoying behavior:

The podman command was in path, and it must not be, so a did:


which podman

nix-env --query | cat

nix-env --uninstall podman-wrapper-2.1.1

A improved version:
nix-env --query --installed --out-path | cat


podman unshare cat /proc/self/uid_map
If this only shows 1 line, then you have not setup 
/etc/subuid and /etc/subgid properly or your newuidmap and newgidmap tools are not install properly. [from](https://github.com/containers/podman/issues/2788#issuecomment-702381214)

## WIP with 

```
git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless
git checkout X

nix develop
```

Why `sudo --preserve-env su -c 'nix develop'` prints:
```
bash: cannot set terminal process group (-1): Inappropriate ioctl for device
bash: no job control in this shell
Entering the nix devShell
bash: cannot set terminal process group (14581): Inappropriate ioctl for device
bash: no job control in this shell
```

Why even using `nix develop --ignore-environment` the docker binary still in path? 
See `readlink $(which docker)`.

TODO: maybe it is the problem?

ls /etc/cni/net.d/ 
ls /opt/cni/bin 

https://github.com/containers/podman/issues/3679#issuecomment-588187954

`ls /nix/store/* | grep cni-`

## Credits and history

TODO: improve it, i am busy trying to make it work first.

- While searching for some problem that i was facing i have found 
  [this issue comment](https://github.com/NixOS/nixpkgs/issues/65202#issuecomment-558775869) from
  [adisbladis](https://github.com/adisbladis), it was pointing to 
  [a gist that he have done](https://gist.github.com/adisbladis/187204cb772800489ee3dac4acdd9947). I didn't
  test it in [NixOS](https://gist.github.com/adisbladis/187204cb772800489ee3dac4acdd9947), but was able 
  to use the `nix-shell` (it was intended to be used as `nix-shell`) and tranform it in a flake and do
  some crazy stuff to combine it in other flakes take a look at the 
  [example of nix, flakes, shellHook, writeShellScriptBin, defaultPackage, all together](https://github.com/ES-Nix/nix-flakes-shellHook-writeShellScriptBin-defaultPackage)
  that uses what i did in this rev [170f002d76070b1d281cf7e6868076bcfb1fea07](https://github.com/ES-Nix/podman-rootless/tree/170f002d76070b1d281cf7e6868076bcfb1fea07).
  But a faced a problem, the file system, yes, even this kind of stuff to make things break. Podman was working really ok,
  but when i tried to load a "big" [OCI image](https://github.com/opencontainers/image-spec) with size > 0.5Gbyte it broke.
  The podman mantainers say "[We recommend using fuse-overlayfs instead, as it is capable of deduplicating storage.](https://github.com/containers/podman/issues/3846#issuecomment-522332015)"
  So now i am trying to use [buildFHSUserEnv](https://gsc.io/70266391-48a6-49be-ab5d-acb5d7f17e76-nixpkgs/doc/nixpkgs-manual/html/sec-fhs-environments.html), definition in nixpokgs [buildFHSUserEnv](https://github.com/NixOS/nixpkgs/blob/cb6d8368a3f6484c1c7f27475b8b4ebe0275dc1a/pkgs/build-support/build-fhs-userenv/default.nix)
  to solve it adapting the [danieldk commented](https://github.com/NixOS/nixpkgs/issues/65202#issuecomment-593103989).
- TODO  


## About FHS

Excelent: [On Nix, NixOS and the Filesystem Hierarchy Standard (FHS)](http://sandervanderburg.blogspot.com/2011/11/on-nix-nixos-and-filesystem-hierarchy.html)
