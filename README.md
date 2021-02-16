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

