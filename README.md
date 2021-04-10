# podman-rootless

Example of using `nix` + `flakes` to have podman rootless working!

Oneliner:
`nix develop github:ES-Nix/podman-rootless/c4a29329c0fc53b1281657baed829a4a8b011cf1`

nix develop github:ES-Nix/podman-rootless/8a8cd879d361bb57ecbbd05fa60685c7b9601fea

```
git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless/
git checkout feature/tests
```

Broken: maybe only using PAT it works?
```
nix flake clone github:ES-Nix/podman-rootless --dest podman-rootless
```
nix develop github:ES-Nix/podman-rootless/324855d116d15a0b54f33c9489cf7c5e6d9cd714 --command ./install-podman.sh && ./test_podman-rootless.sh


```
IMAGE_VERSION='localhost/nix-oci-dockertools:0.0.1'
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--workdir=/code \
--volume="$(pwd)":/code \
"$IMAGE_VERSION" \
bash \
-c "sudo ls -al && id"
```

Usefull for show the created scripts:
`cat $(which extraPodman)`


# direnv

Trying:
- https://github.com/nix-community/nix-direnv
- https://discourse.nixos.org/t/nix-direnv-1-1rc1-released-flake-support/8526/8 

```
stat ~/.config/nix/nix.conf

echo 'keep-derivations = true' >> ~/.config/nix/nix.conf
echo 'keep-outputs = true' >> ~/.config/nix/nix.conf    

touch ~/.direnvrc                     

echo 'source /run/current-system/sw/share/nix-direnv/direnvrc' >> ~/.direnvrc

DIRENV_PATH=$(echo /nix/store/*-nix-direnv-1.2.4/)/share/nix-direnv

export PATH="$DIRENV_PATH":"$PATH"

echo "use nix" >> .envrc
direnvrc allow
```
