{ pkgs ? import <nixpkgs> { } }:
let
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
      if [ "$(id --user)" = "0" ]; then
        # Dont overwrite customised configuration
        if ! test -f /etc/containers/policy.json; then
          install -Dm555 ${pkgs.skopeo.src}/default-policy.json /etc/containers/policy.json
        fi

        if ! test -f /etc/containers/registries.conf; then
          install -Dm555 ${registriesConf} /etc/containers/registries.conf
        fi

      else
        # Dont overwrite customised configuration
        if ! test -f ~/.config/containers/policy.json; then
          install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
        fi

        if ! test -f ~/.config/containers/registries.conf; then
          install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
        fi
      fi
    '';

  fullPathNewugidmap = ''# set -x
    full_path_newugidmap() {

        BIN_NAME_TO_FIND_FULL_PATH=$1
        if ! ${pkgs.coreutils}/bin/stat $(${pkgs.which}/bin/which "$BIN_NAME_TO_FIND_FULL_PATH" 2> /dev/null) >/dev/null 2>&1; then
          exit 100
        fi

        # echo "$BIN_NAME_TO_FIND_FULL_PATH"

        if ${pkgs.coreutils}/bin/readlink --canonicalize $(${pkgs.which}/bin/which "$BIN_NAME_TO_FIND_FULL_PATH") >/dev/null 2>&1; then
          echo $(${pkgs.coreutils}/bin/readlink --canonicalize $(${pkgs.which}/bin/which "$BIN_NAME_TO_FIND_FULL_PATH"))
          exit 0
        fi

        if ${pkgs.coreutils}/bin/stat $(${pkgs.which}/bin/which "$BIN_NAME_TO_FIND_FULL_PATH") >/dev/null 2>&1; then
          echo $(${pkgs.which}/bin/which "$BIN_NAME_TO_FIND_FULL_PATH")
          exit 0
        fi
  }'';

  setcapChmod = ''# set -x
      setcap_chmod() {

        CAPABILITIE_TO_SET="$1"
        FULL_BINARY_PATH="$2"

        # The u+s also works
        VALUE_TO_CHMOD='4755'

        # echo "$CAPABILITIE_TO_SET"
        # echo "$FULL_BINARY_PATH"
#        VERBOSE="-v"

        if [ "$(${pkgs.coreutils}/bin/id --user)" = "0" ]; then
          ${pkgs.libcap}/bin/setcap "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
          ${pkgs.coreutils}/bin/chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"
        else
          if sudo --version >/dev/null 2>&1; then
            # echo "sudo was found in PATH, trying to setcap and chmod for newuidmap"

            sudo ${pkgs.coreutils}/bin/chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"

#            echo "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
            sudo setcap "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
#            ${pkgs.libcap}/bin/getcap "$FULL_BINARY_PATH"
#            sudo ${pkgs.libcap}/bin/setcap -v "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
          else
            echo 'You are not either root or have sudo. Failed to install.'
            exit 100
          fi
        fi
  }'';

  checkNixStoreWritible = ''# set -x
    check_nix_store_writible() {
      if ! ${pkgs.coreutils}/bin/test -w /nix; then
        echo 'Not able to write to /nix. Failed to install.'
        exit 101
      fi
    }
  '';

  podmanSetcapHack = pkgs.writeShellScriptBin "podman-setcap-hack" ''

      ${fullPathNewugidmap}
      ${setcapChmod}
      ${checkNixStoreWritible}

      CAP_SETUID='cap_setuid=+ep'
      CAP_SETGID='cap_setgid=+ep'

      # https://github.com/containers/podman/issues/2788#issuecomment-479972943
      if newuidmap >/dev/null 2>&1; then
        if ! ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newuidmap) | grep -q "$CAP_SETUID"; then
          check_nix_store_writible
          setcap_chmod "$CAP_SETUID" "$(full_path_newugidmap newuidmap)"
        fi
      else # If newuidmap was not found try to install it!
        check_nix_store_writible
        nix profile install nixpkgs#shadow
        setcap_chmod "$CAP_SETUID" ${pkgs.shadow}/bin/newuidmap
        # Uncomment it when debug
#        echo '.'
#        echo $(full_path_newugidmap newuidmap)
#        stat $(full_path_newugidmap newuidmap)
#        ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newuidmap)
      fi

      #
      if newgidmap >/dev/null 2>&1; then
        if ! ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newgidmap) | grep -q "$CAP_SETGID"; then
          check_nix_store_writible
          setcap_chmod "$CAP_SETGID" "$(full_path_newugidmap newgidmap)"
        fi
      else # If newgidmap was not found try to install it!
        check_nix_store_writible
        nix profile install nixpkgs#shadow
        setcap_chmod "$CAP_SETGID" ${pkgs.shadow}/bin/newgidmap
        # Uncomment it when debugging
#        echo '.'
#        echo $(full_path_newugidmap newgidmap)
#        stat $(full_path_newugidmap newgidmap)
#        ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newgidmap)
      fi
  '';

  # Provides a fake "docker" binary mapping to podman
  dockerPodmanCompat = pkgs.runCommandNoCC "docker-podman-compat" { } ''
    mkdir --parent $out/bin
    ln --symbolic ${pkgs.podman}/bin/podman $out/bin/docker
  '';

  podmanClearConfigFiles = pkgs.writeShellScriptBin "podman-clear-config-files" ''
    rm --force --verbose ~/.config/containers/policy.json
    rm --force --verbose ~/.config/containers/registries.conf
  '';

  podmanClearItsData = pkgs.writeShellScriptBin "podman-clear-its-data" ''
    # TODO: it needs tests!
    podman ps --all --quiet | xargs --no-run-if-empty podman rm --force \
    && podman images --quiet | xargs --no-run-if-empty podman rmi --force \
    && podman container prune --force \
    && podman images --quiet | podman image prune --force \
    && podman network ls --quiet | xargs --no-run-if-empty podman network rm \
    && podman volume prune --force
    podman pod list --quiet | xargs --no-run-if-empty podman pod rm --force
  '';

  podmanWrapper = pkgs.writeShellScriptBin "podman" ''
    ${podmanSetupScript}/bin/podman-setup-script
    ${podmanSetcapHack}/bin/podman-setcap-hack

    # Uncomment it when debug
#    ${fullPathNewugidmap}
#    stat /nix/store/4l5d0r8s399g4mvmcsh9a12307axv4pm-shadow-4.8.1/bin/newuidmap
#    echo $(full_path_newugidmap newuidmap)

    ${pkgs.podman}/bin/podman "$@"
  '';

in
pkgs.stdenv.mkDerivation {
  name = "podman-rootless-derivation";
  buildInputs = with pkgs; [
    podmanClearItsData
    podmanWrapper
    podmanSetcapHack
    podmanSetupScript

    # dockerPodmanCompat
  ];


  # buildPhase = dockerPodmanCompat;

  installPhase = ''
    mkdir --parent $out/bin

    # install -t $out/bin ${pkgs.podman}/bin/podman
    
    install -t $out/bin ${podmanClearConfigFiles}/bin/podman-clear-config-files
    install -t $out/bin ${podmanClearItsData}/bin/podman-clear-its-data
    install -t $out/bin ${podmanSetcapHack}/bin/podman-setcap-hack
    install -t $out/bin ${podmanSetupScript}/bin/podman-setup-script
    install -t $out/bin ${podmanWrapper}/bin/podman
  '';

  phases = [ "buildPhase" "installPhase" "fixupPhase" ];

}
