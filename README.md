# podman-rootless
Example of using nix + flakes to have podman rootless working



nix flake clone github:ES-Nix/podman-rootless --dest podman-rootless

nix develop github:ES-Nix/podman-rootless/324855d116d15a0b54f33c9489cf7c5e6d9cd714 --command ./install-podman.sh && ./test_podman-rootless.sh


`nix develop github:ES-Nix/podman-rootless/c4a29329c0fc53b1281657baed829a4a8b011cf1`



IMAGE_VERSION='localhost/nix-oci-dockertools:0.0.1'

podman run \
--interactive \
--tty \
--rm \
--workdir /code \
--volume "$(pwd)":/code \
"$IMAGE_VERSION" bash -c "sudo ls -al && id"



if ! getcap "$NEWUIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' && getcap "$NEWGIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' ; then
  setcap cap_setuid+ep "$NEWUIDMAP"
  setcap cap_setgid+ep "$NEWGIDMAP"
fi

setcap cap_setuid+ep "$NEWUIDMAP"

cat $(which extraPodman)

git clone https://github.com/ES-Nix/podman-rootless.git
cd podman-rootless/
git checkout feature/tests



# direnv


stat ~/.config/nix/nix.conf

echo 'keep-derivations = true' >> ~/.config/nix/nix.conf
echo 'keep-outputs = true' >> ~/.config/nix/nix.conf    

touch ~/.direnvrc                     

echo 'source /run/current-system/sw/share/nix-direnv/direnvrc' >> ~/.direnvrc

DIRENV_PATH=$(echo /nix/store/*-nix-direnv-1.2.4/)/share/nix-direnv

export PATH="$DIRENV_PATH":"$PATH"

echo "use nix" >> .envrc
direnvrc allow
