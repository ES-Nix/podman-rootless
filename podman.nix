{ pkgs ? import <nixpkgs> { } }:
let
  podmanCapabilities = pkgs.writeShellScriptBin "podman-capabilities" ''
    # For now using this hack, beenig impure using/calling sudo
    # for fixing capabilities.
    # The sudo call must happen only in the first time.
    # Note that it should work if it is ran as root without
    # calling/needing `sudo`.
    #
    # We should check for the actual capabilitie and if they are
    # the ones that podman needs skip the set of the capabilitie.

    if ! getcap /nix/store/*-podman-rootless-derivation/bin/newuidmap | grep -q cap_setuid+ep; then
      if [ "$(id -u)" = "0" ]; then
        setcap cap_setuid+ep /nix/store/*-podman-rootless-derivation/bin/newuidmap
      else
        echo 'Fixing capabilities. It requires sudo, sorry!'
        sudo setcap cap_setuid+ep /nix/store/*-podman-rootless-derivation/bin/newuidmap
      fi
    fi

    if ! getcap /nix/store/*-podman-rootless-derivation/bin/newgidmap | grep -q cap_setgid+ep; then
      if [ "$(id -u)" = "0" ]; then
        setcap cap_setgid+ep /nix/store/*-podman-rootless-derivation/bin/newgidmap
      else
        echo 'Fixing capabilities. It requires sudo, sorry!'
        sudo setcap cap_setgid+ep /nix/store/*-podman-rootless-derivation/bin/newgidmap
      fi
    fi

    # Another way would be use `which` and `readlink`. May be use toybox to do this?
    # echo 'Fixing capabilities. It requires sudo, sorry!'
    # NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
    # NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))
#
#    RO_OR_RW=$(test-read-only-path)
#    echo 'The value is:'"$RO_OR_RW"
#    if [ "$RO_OR_RW" == "rw" ]; then
#      echo 'Calling sudo: '"$RO_OR_RW"
#      sudo setcap cap_setuid+ep "$NEWUIDMAP"
#      sudo setcap cap_setgid+ep "$NEWGIDMAP"
#
#      sudo chmod -s "$NEWUIDMAP"
#      sudo chmod -s "$NEWGIDMAP"
#    fi

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

      storageConf = pkgs.writeText "storage.conf" ''
        [storage]
          driver = "overlay"
          [storage.options]
            mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"
      '';
    in
    pkgs.writeShellScriptBin "podman-setup-script" ''
      # Dont overwrite customised configuration
      if ! test -f ~/.config/containers/policy.json; then
        install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
      fi

      if ! test -f ~/.config/containers/registries.conf; then
        install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
      fi

      # https://github.com/containers/storage/issues/863
      if ! test -f ~/.config/containers/storage.conf; then
        install -Dm555 ${storageConf} ~/.config/containers/storage.conf
      fi
    '';

  # Provides a fake "docker" binary mapping to podman
  dockerPodmanCompat = pkgs.runCommandNoCC "docker-podman-compat" { } ''
    mkdir --parent $out/bin
    ln --symbolic ${pkgs.podman}/bin/podman $out/bin/docker
  '';

  testReadOnlyPath = pkgs.writeShellScriptBin "test-read-only-path" ''
    # https://serverfault.com/a/474078
    NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
    NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

    if [[ -w /nix/store ]]; then
      echo 'rw'
    else
      echo 'ro'
    fi
  '';

  podmanClearConfigFiles = pkgs.writeShellScriptBin "podman-clear-config-files" ''
     rm --force --verbose ~/.config/containers/policy.json
     rm --force --verbose ~/.config/containers/registries.conf
  '';

  podmanClearItsData = pkgs.writeShellScriptBin "podman-clear-its-data" ''
    # TODO: it need tests!
    podman ps --all --quiet | xargs --no-run-if-empty podman rm --force \
    && podman images --quiet | xargs --no-run-if-empty podman rmi --force \
    && podman container prune --force \
    && podman images --quiet | podman image prune --force \
    && podman network ls --quiet | xargs --no-run-if-empty podman network rm \
    && podman volume prune --force
    podman pod list --quiet | xargs --no-run-if-empty podman pod rm --force
  '';

  podmanWrapper = pkgs.writeShellScriptBin "podman" ''
    ${podmanCapabilities}/bin/podman-capabilities
    ${podmanSetupScript}/bin/podman-setup-script
    ${pkgs.podman}/bin/podman "$@"
  '';

in
pkgs.stdenv.mkDerivation {
  name = "podman-rootless-derivation";
  buildInputs = with pkgs; [
    conmon
    cni
    cni-plugins # https://github.com/containers/podman/issues/3679
    coreutils
    fuse-overlayfs # https://gist.github.com/adisbladis/187204cb772800489ee3dac4acdd9947#file-podman-shell-nix-L48
    libcap_progs
    podmanWrapper
    runc
    shadow
    skopeo
    slirp4netns

    #
    # dockerPodmanCompat
  ];
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
    install -t $out/bin ${pkgs.conmon}/bin/conmon
    install -t $out/bin ${pkgs.cni}/bin/cnitool
    install -t $out/bin ${pkgs.cni}/bin/noop
    install -t $out/bin ${pkgs.cni}/bin/sleep

    # How to be DRY here?
    install -t $out/bin ${pkgs.cni-plugins}/bin/bandwidth
    install -t $out/bin ${pkgs.cni-plugins}/bin/bridge
    install -t $out/bin ${pkgs.cni-plugins}/bin/dhcp
    install -t $out/bin ${pkgs.cni-plugins}/bin/firewall
    install -t $out/bin ${pkgs.cni-plugins}/bin/flannel
    install -t $out/bin ${pkgs.cni-plugins}/bin/host-device
    install -t $out/bin ${pkgs.cni-plugins}/bin/host-local
    install -t $out/bin ${pkgs.cni-plugins}/bin/ipvlan
    install -t $out/bin ${pkgs.cni-plugins}/bin/loopback
    install -t $out/bin ${pkgs.cni-plugins}/bin/macvlan
    install -t $out/bin ${pkgs.cni-plugins}/bin/portmap
    install -t $out/bin ${pkgs.cni-plugins}/bin/ptp
    install -t $out/bin ${pkgs.cni-plugins}/bin/sbr
    install -t $out/bin ${pkgs.cni-plugins}/bin/ptp
    install -t $out/bin ${pkgs.cni-plugins}/bin/static
    install -t $out/bin ${pkgs.cni-plugins}/bin/tuning
    install -t $out/bin ${pkgs.cni-plugins}/bin/vlan
    install -t $out/bin ${pkgs.cni-plugins}/bin/vrf

    install -t $out/bin ${pkgs.fuse-overlayfs}/bin/fuse-overlayfs
    # install -t $out/bin ${pkgs.podman}/bin/podman
    install -t $out/bin ${pkgs.runc}/bin/runc
    install -t $out/bin ${pkgs.shadow}/bin/newgidmap
    install -t $out/bin ${pkgs.shadow}/bin/newuidmap
    install -t $out/bin ${pkgs.skopeo}/bin/skopeo
    install -t $out/bin ${pkgs.slirp4netns}/bin/slirp4netns

    install -t $out/bin ${pkgs.libcap_progs}/bin/capsh
    install -t $out/bin ${pkgs.libcap_progs}/bin/getcap
    install -t $out/bin ${pkgs.libcap_progs}/bin/getpcaps
    install -t $out/bin ${pkgs.libcap_progs}/bin/setcap

    install -t $out/bin ${podmanCapabilities}/bin/podman-capabilities
    install -t $out/bin ${podmanSetupScript}/bin/podman-setup-script
    install -t $out/bin ${podmanClearConfigFiles}/bin/podman-clear-config-files
    install -t $out/bin ${podmanClearItsData}/bin/podman-clear-its-data
    install -t $out/bin ${testReadOnlyPath}/bin/test-read-only-path
    install -t $out/bin ${podmanWrapper}/bin/podman
  '';

  phases = [ "buildPhase" "installPhase" "fixupPhase" ];

}
