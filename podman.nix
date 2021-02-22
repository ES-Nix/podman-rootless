{ pkgs ? import <nixpkgs> {} }:

let 

  fhs = pkgs.buildFHSUserEnv {
    
    name = "fsh-podman-rootless-env";

    targetPkgs = pkgs: with pkgs;
      [ 
      conmon
      cni
      cni-plugins # https://github.com/containers/podman/issues/3679
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
      hello # just for tests
      scriptExample
      unixtools.whereis 
      which
      ];

    multiPkgs = pkgs: with pkgs; [ zlib ];
    
    #extraBuildCommands = ''
    #  mkdir --parent $out/test-extraBuildCommands
    #'';
    
    #extraInstallCommands = ''
    #  mkdir --parent $out/etc/containers
    #'';
   
    runScript = "bash";
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

  # https://nix.dev/anti-patterns/language.html#reproducability-referencing-top-level-directory-with
  src = builtins.path { path = ./.; };

  nativeBuildInputs = [ fhs scriptExample ];
  buildInputs = [ etcFiles ];
  installPhase = ''
    mkdir --parent $out
    ln --symbolic --force ${fhs}/bin/fsh-podman-rootless-env $out/fsh-podman-rootless-env
    ln --symbolic --force ${etcFiles}/etc $out/etc

    mkdir --parent $out/opt/cni/
    ln --symbolic --force ${pkgs.cni-plugins} $out/opt/cni
  '';
  phases = [ "installPhase" "fixupPhase"];
}

