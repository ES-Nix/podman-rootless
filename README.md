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

`sudo podman --log-level=debug images`

`dpkg-query -L podman` [Incompatibilities of podman from docker on Travis CI](https://github.com/containers/podman/issues/3679)

Probably the one of the problems, missing this file: https://github.com/containers/podman/tree/master/cni

Use something like this to test the CNI: `podman run --network foo --rm -it alpine ls`
https://github.com/containers/podman/issues/2909#issuecomment-579490909
https://github.com/containernetworking/cni/issues/770#issuecomment-641551771

TODO: how to check it? 
`ip link add cni-podman0 type bridge`
https://github.com/containers/podman/issues/4114#issuecomment-535849590

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


## About Filesystem Hierarchy Standard (FHS)

- Excelent: [On Nix, NixOS and the Filesystem Hierarchy Standard (FHS)](http://sandervanderburg.blogspot.com/2011/11/on-nix-nixos-and-filesystem-hierarchy.html)
- Sander van der Burg is the creator of [buildFHSUserEnv](https://gsc.io/70266391-48a6-49be-ab5d-acb5d7f17e76-nixpkgs/doc/nixpkgs-manual/html/sec-fhs-environments.html), must read: [Composing FHS-compatible chroot environments with Nix (or deploying Steam in NixOS)](http://sandervanderburg.blogspot.com/2013/09/composing-fhs-compatible-chroot.html)
- Podman official documentation: [Unsupported file systems in rootless mode](http://docs.podman.io/en/latest/markdown/podman.1.html#note-unsupported-file-systems-in-rootless-mode)
- Maintainers in the podman repository ["we recommend using fuse-overlayfs"](https://github.com/containers/podman/issues/3846#issuecomment-522332015)
- [Rootless Containers](https://rootlesscontaine.rs)

- YouTube ExplainingComputers: [Explaining File Systems: NTFS, exFAT, FAT32, ext4 & More](https://www.youtube.com/watch?v=_h30HBYxtws)
- YouTube Joe Collins: [Learning the Linux File System](https://www.youtube.com/watch?v=HIXzJ3Rz9po)
- YouTube EuroBSDCon2014: [FUSE and beyond: bridging filesystems by Emannuel Dreyfus](https://www.youtube.com/watch?v=Yd6dy98BRtQ)
- YouTube The Linux Man: [Linux File System Types](https://www.youtube.com/watch?v=g7OkSvioFlU)
- developer.ibm [Anatomy of ext4](https://developer.ibm.com/technologies/systems/tutorials/l-anatomy-ext4/)
- [Linux Filesystems: Where did they come from? [linux.conf.au 2014]](https://www.youtube.com/watch?v=SMcVdZk7wV8)
- TODO watch it [A Study of Linux File System Evolution](https://www.usenix.org/conference/fast13/technical-sessions/presentation/lu)
- TODO find scientific papers that go even more deeper in all this [Understanding Linux filesystems: ext4 and beyond](https://opensource.com/article/18/4/ext4-filesystem)
- TODO replicate it using flakes [Making a Simple Deb Package NixOS Compatible (Mathematica's wolframscript)](https://unix.stackexchange.com/questions/520675/making-a-simple-deb-package-nixos-compatible-mathematicas-wolframscript)


[RAID 0, RAID 1, RAID 10 - All You Need to Know as Fast As Possible](https://www.youtube.com/watch?v=eE7Bfw9lFfs), 
it looks like it is really old and [SSDs have changed it all](https://www.youtube.com/watch?v=eE7Bfw9lFfs&lc=UgwKswMApMLxMfVBK0V4AaABAg.8w0pXYZxjGI9-gxFP336ZB)
[RAID 5 & RAID 6 - All You Need to Know as Fast As Possible](https://www.youtube.com/watch?v=1P8ZecG9iOI).

Explains about history in the beginning: [btrfs: The Best Filesystem You've Never Heard Of](https://www.youtube.com/watch?v=-m01x3gHNjg)
[Deploying Btrfs at Facebook Scale - Josef Bacik, Facebook](https://www.youtube.com/watch?v=U7gXR2L05IU)

[File Systems | Which One is the Best? ZFS, BTRFS, or EXT4](https://www.youtube.com/watch?v=HdEozE2gN9I)


[All File Systems Are Not Created Equal: On the Complexity of Crafting Crash-Consistent Applications](https://www.usenix.org/conference/osdi14/technical-sessions/presentation/pillai)

TODO: Try to make it work:   
https://discourse.nixos.org/t/build-a-yocto-rootfs-inside-nix/2643/22

TODO: Find the refs it cites [In-depth: ELF - The Extensible & Linkable Format](https://www.youtube.com/watch?v=nC1U1LJQL8o)
and find an example of hardcoded path in the ELF and make from zero one working example.
[2013 Day2P18 LoB: ELF Intro](https://www.youtube.com/watch?v=t09LFtfy4JU)



## Running as root





```
sudo \
--preserve-env \
su \
--preserve-env \
root \
-c 'nix develop --ignore-environment'
```

```
su \
--preserve-env \
pedro \
-c 'echo 123 | sudo --stdin podman images'
```

Why the `--login` gives problems? It somehow scruds with the terminal!

0b4d0714bfaab2d3fd45176699658c1ae5437742


```
git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless
git checkout 0b4d0714bfaab2d3fd45176699658c1ae5437742
nix develop
```


sudo \
--preserve-env \
su \
--preserve-env \
root \
-c 'nix develop --ignore-environment github:ES-Nix/podman-rootless'
