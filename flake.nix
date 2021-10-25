{
  description = "This is a nix flake podman rootless wrapper";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "podman";
        pkgs = import nixpkgs {
          inherit system;
        };

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
#              VERBOSE="-v"

              if [ "$(${pkgs.coreutils}/bin/id --user)" = "0" ]; then
                ${pkgs.libcap}/bin/setcap "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
                ${pkgs.coreutils}/bin/chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"
              else
                if sudo --version >/dev/null 2>&1; then
                  # echo "sudo was found in PATH, trying to setcap and chmod for newuidmap"

                  sudo ${pkgs.coreutils}/bin/chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"

#                  echo "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
                  sudo setcap "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
                  ${pkgs.libcap}/bin/getcap "$FULL_BINARY_PATH"
                  sudo ${pkgs.libcap}/bin/setcap -v "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
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
            # https://stackoverflow.com/a/677212
            # if newuidmap >/dev/null 2>&1; then
            # if ${pkgs.coreutils}/bin/stat $(${pkgs.which}/bin/which newuidmap 2> /dev/null) >/dev/null 2>&1; then
            if ${pkgs.bash}/bin/command -v newuidmap &> /dev/null; then
              if ! ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newuidmap) | grep -q "$CAP_SETUID"; then
                check_nix_store_writible
                setcap_chmod "$CAP_SETUID" "$(full_path_newugidmap newuidmap)"
              fi
            else # If newuidmap was not found try to install it!
              check_nix_store_writible
              nix profile install nixpkgs#shadow
              setcap_chmod "$CAP_SETUID" "$(full_path_newugidmap newuidmap)"
              # Uncomment it when debug
#              echo '.'
#              echo $(full_path_newugidmap newuidmap)
#              stat $(full_path_newugidmap newuidmap)
#              ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newuidmap)
            fi

            #
            if ${pkgs.bash}/bin/command -v newgidmap &> /dev/null; then
              if ! ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newgidmap) | grep -q "$CAP_SETGID"; then
                check_nix_store_writible
                setcap_chmod "$CAP_SETGID" "$(full_path_newugidmap newgidmap)"
              fi
            else # If newgidmap was not found try to install it!
              check_nix_store_writible
              nix profile install nixpkgs#shadow
              setcap_chmod "$CAP_SETGID" "$(full_path_newugidmap newgidmap)"
              # Uncomment it when debugging
#              echo '.'
#              echo $(full_path_newugidmap newgidmap)
#              stat $(full_path_newugidmap newgidmap)
#              ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newgidmap)
            fi
        '';

      in
      rec {

        # `nix build`
        packages.${name} = import ./podman.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        defaultPackage = packages.${name};

        # `nix develop`
        devShell = pkgs.mkShell {

          buildInputs = with pkgs; [
            self.defaultPackage.${system}
            self.packages.${system}.podman
            podmanSetcapHack
          ];

          # inputsFrom = [ self.defaultPackage ];
          # inputsFrom = builtins.attrValues self.packages.${system};

          shellHook = ''
            # TODO: document this
            export TMPDIR=/tmp

            # Uncomment it when debug
            ${fullPathNewugidmap}
#    stat /nix/store/4l5d0r8s399g4mvmcsh9a12307axv4pm-shadow-4.8.1/bin/newuidmap
#    echo $(full_path_newugidmap newuidmap)
            podman-setcap-hack
          '';
        };

        # `nix run`
        apps.${name} = flake-utils.lib.mkApp {
          inherit name;
          drv = packages.${name};
        };

        defaultApp = apps.${name};

        checks = {
          nixpkgs-fmt = pkgs.runCommand "check-nix-format" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            mkdir $out #sucess
          '';

          build = self.defaultPackage.${system};
          # build = packages.${name};
        };

        # hydraJobs = self.packages;
        # https://www.tweag.io/blog/2020-07-31-nixos-flakes/
        # hydraJobs.build = self.defaultPackage.${system};
      });
}

