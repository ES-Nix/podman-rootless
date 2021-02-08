{ pkgs ? import <nixpkgs> { } }:
let

  myScript = pkgs.writeShellScriptBin "compleInstallPodman" ''
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
#  buildPhase = ''
#    mkdir --parent $out
#    cp -arv ${pkgs.conmon}/bin/conmon $out/conmon
#    cp -arv ${pkgs.runc}/bin/runc $out/runc
#    cp -arv ${pkgs.shadow}/bin/newuidmap $out/newuidmap
#    cp -arv ${pkgs.shadow}/bin/newgidmap $out/newgidmap
#    cp -arv ${pkgs.slirp4netns}/bin/slirp4netns $out/slirp4netns
#
#    cp -arv ${myScript} $out/myScript
#
#  '';

  installPhase = ''
    mkdir --parent $out/bin;
    install -t $out/bin ${pkgs.podman}/bin/podman
    install -t $out/bin ${pkgs.conmon}/bin/conmon
    install -t $out/bin ${pkgs.runc}/bin/runc
    install -t $out/bin ${pkgs.shadow}/bin/newuidmap
    install -t $out/bin ${pkgs.shadow}/bin/newgidmap
    install -t $out/bin ${pkgs.slirp4netns}/bin/slirp4netns
    install -t $out/bin ${myScript}/bin/compleInstallPodman
    '';

  phases = [ "buildPhase" "installPhase" "fixupPhase" ];

}