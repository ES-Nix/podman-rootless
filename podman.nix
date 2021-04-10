{ pkgs ? import <nixpkgs> { } }:
let

  myScript = pkgs.writeShellScriptBin "compleInstallPodman" ''
    #!${pkgs.stdenv.shell}
    echo 'The wrapper!'
  '';

in
pkgs.stdenv.mkDerivation {
  name = "podman-rootless-derivation";
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

  installPhase = "";

  src = builtins.path { path = ./.; name = "myproject"; };
}
