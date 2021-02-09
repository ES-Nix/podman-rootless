{pkgs ? import <nixpkgs> { } }:
let
        podmanCapabilities = pkgs.writeShellScriptBin "podman-capabilities" ''
          #!${pkgs.runtimeShell}

          # TODO: add a conditional here to run this message only when
          # needs a sudo call, i mean, only the first time problably.
          # No call for sudo is neede after de first time (in most cases)
          # We should check for the actual capabilitie and if they are
          # the ones that podman needs skip the sudo calls.

          #echo 'Fixing capabilities. It requires sudo, sorry!'
          NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
          NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

          sudo setcap cap_setuid+ep "$NEWUIDMAP"
          sudo setcap cap_setgid+ep "$NEWGIDMAP"

          sudo chmod -s "$NEWUIDMAP"
          sudo chmod -s "$NEWGIDMAP"
        '';

        # Provides a script that copies required files to ~/
        podmanSetupScript =
          let
            registriesConf = pkgs.writeText "registries.conf" ''
              [registries.search]
              registries = ['docker.io']
              [registries.block]
              registries = []
            '';
          in
          pkgs.writeShellScriptBin "podman-setup-script" ''
            #!${pkgs.runtimeShell}
            # Dont overwrite customised configuration
            if ! test -f ~/.config/containers/policy.json; then
              install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
            fi
            if ! test -f ~/.config/containers/registries.conf; then
              install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
            fi
          '';

        # Provides a fake "docker" binary mapping to podman
        dockerPodmanCompat = pkgs.runCommandNoCC "docker-podman-compat" { } ''
          mkdir --parent $out/bin
          ln --symbolic ${pkgs.podman}/bin/podman $out/bin/docker
        '';

        podmanClearConfigFiles = pkgs.writeShellScriptBin "podman-clear-config-files" ''
          #!${pkgs.runtimeShell}

           rm --force --verbose ~/.config/containers/policy.json
           rm --force --verbose ~/.config/containers/registries.conf
        '';

        podmanClearItsData = pkgs.writeShellScriptBin "podman-clear-its-data" ''
          #!${pkgs.runtimeShell}

          # TODO: it need tests!
          podman ps --all --quiet | xargs --no-run-if-empty podman stop \
          && podman ps --all --quiet | xargs --no-run-if-empty podman rm --force\
          && podman images --quiet | xargs --no-run-if-empty podman rmi --force \
          && podman container prune --force \
          && podman images --quiet | podman image prune --force \
          && podman network ls --quiet | xargs --no-run-if-empty podman network rm \
          && podman volume ls --quiet | xargs --no-run-if-empty podman volume prune
        '';

in
pkgs.stdenv.mkDerivation {
  name = "test-derivation";
  buildInputs = with pkgs; [
    conmon
    podman
    runc
    shadow
    slirp4netns
    dockerPodmanCompat
  ];

  # TODO: What is the correct way to do this:
  # https://github.com/NixOS/nixpkgs/issues/23099#issue-209660108
  #
  #src = builtins.filterSource (path: type: false) ./.;
  #unpackPhase = "true";
  #src = self;
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

  #buildPhase = dockerPodmanCompat;

  installPhase = ''
    mkdir --parent $out/bin;
    install -t $out/bin ${pkgs.podman}/bin/podman
    install -t $out/bin ${pkgs.conmon}/bin/conmon
    install -t $out/bin ${pkgs.runc}/bin/runc
    install -t $out/bin ${pkgs.shadow}/bin/newuidmap
    install -t $out/bin ${pkgs.shadow}/bin/newgidmap
    install -t $out/bin ${pkgs.slirp4netns}/bin/slirp4netns

    install -t $out/bin ${podmanCapabilities}/bin/podman-capabilities
    install -t $out/bin ${podmanSetupScript}/bin/podman-setup-script
    install -t $out/bin ${podmanClearConfigFiles}/bin/podman-clear-config-files
    install -t $out/bin ${podmanClearItsData}/bin/podman-clear-its-data

    '';

  phases = [ "buildPhase" "installPhase" "fixupPhase" ];

}
