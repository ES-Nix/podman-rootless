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
 

Other somewhat hard tests:

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

rm -rf ~/.config/containers ~/.local/share/containers

Use the `--log-level=debug`, really usefull!

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
  So now i am trying to use [buildFHSUserEnv](https://gsc.io/70266391-48a6-49be-ab5d-acb5d7f17e76-nixpkgs/doc/nixpkgs-manual/html/sec-fhs-environments.html)
  to solve it adapting the [danieldk commented](https://github.com/NixOS/nixpkgs/issues/65202#issuecomment-593103989).
- TODO  
