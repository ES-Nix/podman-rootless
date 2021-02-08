{ pkgs ? import <nixpkgs> { } }:
let

  myScript = pkgs.writeShellScript "compleInstallPodman" ''
    #!${pkgs.stdenv.shell}
    echo 'The wrapper!'
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
  ];
  #src = builtins.filterSource (path: type: false) ./.;
  #unpackPhase = "true";
  buildPhase = ''
    mkdir --parent $out
    cp -arv ${pkgs.podman}/bin/podman $out/podman
    cp -arv ${pkgs.conmon}/bin/conmon $out/conmon
    cp -arv ${pkgs.runc}/bin/runc $out/runc
    cp -arv ${pkgs.shadow}/bin/newuidmap $out/newuidmap
    cp -arv ${pkgs.shadow}/bin/newgidmap $out/newgidmap
    cp -arv ${pkgs.slirp4netns}/bin/slirp4netns $out/slirp4netns

    cp -arv ${myScript} $out/myScript

  '';
  phases = [ "buildPhase" "fixupPhase" ];

}