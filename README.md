# podman-rootless
Example of using nix + flakes to have podman rootless working



nix flake clone github:ES-Nix/podman-rootless --dest podman-rootless

nix develop github:ES-Nix/podman-rootless/324855d116d15a0b54f33c9489cf7c5e6d9cd714 --command ./install-podman.sh && ./test_podman-rootless.sh




IMAGE_VERSION='localhost/nix-oci-dockertools:0.0.1'

podman run \
--interactive \
--tty \
--rm \
--workdir /code \
--volume "$(pwd)":/code \
"$IMAGE_VERSION" bash -c "sudo ls -al && id"



if ! ${pkgsAllowUnfree.libcap}/bin/getcap "$NEWUIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' && ${pkgsAllowUnfree.libcap}/bin/getcap "$NEWGIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' ; then
#${pkgsAllowUnfree.libcap/bin/setcap} cap_setuid+ep $(readlink --canonicalize $(which newuidmap))
#${pkgsAllowUnfree.libcap/bin/setcap} cap_setgid+ep $(readlink --canonicalize $(which newgidmap))
fi