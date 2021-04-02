{ pkgs ? import <nixpkgs> { } }:
let

  myScript = pkgs.writeShellScriptBin "compleInstallPodman" ''
    #!${pkgs.stdenv.shell}
    echo 'The wrapper!'
    ${pkgs.libcap/bin/setcap} cap_setuid+ep $(readlink --canonicalize $(which newuidmap))
    ${pkgs.libcap/bin/setcap} cap_setgid+ep $(readlink --canonicalize $(which newgidmap))

    chmod -s $(readlink --canonicalize $(which newuidmap))
    chmod -s $(readlink --canonicalize $(which newgidmap))

    # TODO: make test showing it is idempotent and respect if the
    # folder has some thing in it.
    mkdir --mode=755 --parent ~/.config/containers --verbose

    cat << EOF > ~/.config/containers/policy.json
    {
        "default": [
            {
                "type": "insecureAcceptAnything"
            }
        ],
        "transports":
            {
                "docker-daemon":
                    {
                        "": [{"type":"insecureAcceptAnything"}]
                    }
            }
    }
    EOF
  '';

in
pkgs.stdenv.mkDerivation {
  name = "test-derivation";
  buildInputs = with pkgs; [
    myScript
    conmon
    podman
    runc
    shadow
    slirp4netns
    docker-compose
    #geogebra
  ];
}
