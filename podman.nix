{ pkgs ? import <nixpkgs> {} }:

let 

  fhs = pkgs.buildFHSUserEnv {
    name = "fsh-podman-rootless-env";
    targetPkgs = pkgs: with pkgs;
      [ 
      conmon
      etcFiles
      fuse-overlayfs
      file
      podman
      libcap
      runc
      skopeo
      slirp4netns
      shadow
      dbus
      hello 
      scriptExample
      unixtools.whereis 
      which
      ];


    multiPkgs = pkgs: with pkgs;
      [ zlib ];
    runScript = "${pkgs.podman}/bin/podman";
  };

  scriptExample = pkgs.writeShellScriptBin "script-example" ''
    #!${pkgs.runtimeShell}
 
      echo 'A bash script example!'
  '';
 
  registriesConf = pkgs.writeText "registries.conf" ''
    [registries.search]
    registries = ['docker.io']
    [registries.block]
    registries = []
  '';
  etcFiles = pkgs.runCommandNoCC "setup-etc" {} ''
    mkdir -p $out/etc/containers 
    ln -s ${pkgs.skopeo.src}/default-policy.json \
     $out/etc/containers/policy.json
    ln -s ${registriesConf} $out/etc/containers/registries.conf
    ln -s /host/etc/subuid $out/etc/subuid
    ln -s /host/etc/subgid $out/etc/subgid
  '';


in pkgs.stdenv.mkDerivation {
  name = "fhs-env-derivation";

  src = ./.;

  nativeBuildInputs = [ fhs scriptExample ];
  buildInputs = [ etcFiles ];
  installPhase = ''
    mkdir --parent $out
    ln -sf ${fhs}/bin/fsh-podman-rootless-env $out/fsh-podman-rootless-env
    
    ln -sf ${scriptExample}/bin/script-example $out/script-example
    ln -sf ${etcFiles}/bin/setup-etc $out/setup-etc
  '';

  shellHook = ''    
    exec ${fhs}/bin/fsh-podman-rootless-env
  '';

  phases = [ "installPhase" "fixupPhase"];
}

