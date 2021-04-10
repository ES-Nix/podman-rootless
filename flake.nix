{
  description = "This is a nix flake podman rootless package";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgsAllowUnfree = import nixpkgs {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };

        myScript = pkgsAllowUnfree.writeShellScriptBin "sets-needed-podman-capabilities" ''

          # Recomended read about capabilities
          # https://unix.stackexchange.com/questions/388500/when-using-setcap-where-is-the-permission-stored?rq=1
          #set -x
          # TODO: Not sure if it is working!
          # add a conditional here to run this mesage only when
          # needs a sudo call, i mean, only the first time problably.
          # No call for sudo is neede after de first time (in most cases)
          # We should check for the actual capabilitie and if they are 
          # the ones that podman needs skip the sudo calls.

          FULL_PATH_NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
          FULL_PATH_NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

          if ! command -v sudo &> /dev/null
          then
            echo 'Fixing capabilities. It requires sudo, sorry!'
            echo 'Well, sudo is NOT in the PATH'
            echo 'Printing the PATH:' "$PATH"
            exit 1
          fi

          if ! (( getcap "$FULL_PATH_NEWUIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' || getcap "$FULL_PATH_NEWGIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setgid+ep' )); then
            echo 'Calling sudo to setcap of:' "$FULL_PATH_NEWUIDMAP"
            sudo setcap cap_setuid+ep "$FULL_PATH_NEWUIDMAP"

            echo 'Calling sudo to setcap of:' "$FULL_PATH_NEWGIDMAP"
            sudo setcap cap_setgid+ep "$FULL_PATH_NEWGIDMAP"
          fi

       '';

        messCapabilities = pkgsAllowUnfree.writeShellScriptBin "mess-capabilities" ''
          #set -x
          # TODO: add a conditional here to run this mesage only when
          # needs a sudo call, i mean, only the first time problably.
          # No call for sudo is neede after de first time (in most cases)
          # We should check for the actual capabilitie and if they are
          # the ones that podman needs skip the sudo calls.

          FULL_PATH_NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
          FULL_PATH_NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

          echo 'REMOVING capabilities. It requires sudo, sorry!'
          if ! command -v sudo &> /dev/null
          then
            echo 'Well, sudo is NOT in the PATH'
            echo 'Printing the PATH:' "$PATH"
            exit 1
          fi

          echo 'Running setcap -r' for:
          sudo setcap -r "$FULL_PATH_NEWUIDMAP"
          sudo setcap -r "$FULL_PATH_NEWGIDMAP"

          echo 'Running getcap'
          sudo getcap "$FULL_PATH_NEWUIDMAP"
          sudo getcap "$FULL_PATH_NEWGIDMAP"
        '';

        # Provides a script that copies required files to ~/
        podmanSetupScript =
          let
            registriesConf = pkgsAllowUnfree.writeText "registries.conf" ''
              [registries.search]
              registries = ['docker.io']
              [registries.block]
              registries = []
            '';
          in
          pkgsAllowUnfree.writeShellScriptBin "podman-setup" ''
            #!${pkgsAllowUnfree.runtimeShell}
            # Dont overwrite customised configuration
            if ! test -f ~/.config/containers/policy.json; then
              install -Dm555 ${pkgsAllowUnfree.skopeo.src}/default-policy.json ~/.config/containers/policy.json
            fi
            if ! test -f ~/.config/containers/registries.conf; then
              install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
            fi
          '';


        # Provides a fake "docker" binary mapping to podman
        dockerCompat = pkgsAllowUnfree.runCommandNoCC "docker-podman-compat" { } ''
          mkdir --parent $out/bin
          ln --symbolic ${pkgsAllowUnfree.podman}/bin/podman $out/bin/docker
        '';

        cleanPodmanSetup = pkgsAllowUnfree.writeShellScriptBin "clear-podman-setup" ''
          #!${pkgsAllowUnfree.runtimeShell}
           rm --force --verbose ~/.config/containers/policy.json
           rm --force --verbose ~/.config/containers/registries.conf
        '';

        clearPodmanCreatedContainersAndMore = pkgsAllowUnfree.writeShellScriptBin "podman-clear" ''
          #!${pkgsAllowUnfree.runtimeShell}
    
          # TODO: it need tests!
          podman stop --all --ignore \
          && podman ps --all --quiet | xargs --no-run-if-empty podman rm --force \
          && podman images --quiet | xargs --no-run-if-empty podman rmi --force \
          && podman container prune --force \
          && podman images --quiet | podman image prune --force \
          && podman network ls --quiet | xargs --no-run-if-empty podman network rm \
          && podman volume prune --force
        '';

        podmanCreateIfNotExistis = pkgsAllowUnfree.writeShellScriptBin "podman-create-if-not-existis" ''
          #!${pkgsAllowUnfree.runtimeShell}
            IMAGE="$1"
            echo "$IMAGE"

            if ! (( podman images | rg --quiet --case-sensitive --fixed-strings "$IMAGE" )); then
              echo 'Creating image'
              podman-create-image
            else
              echo 'Using cached image'
            fi
        '';

        podmanWrapper = pkgsAllowUnfree.writeShellScriptBin "podman-wrapper" ''
          #!${pkgsAllowUnfree.runtimeShell}
            podman-setup
            sets-needed-podman-capabilities
            #podman pull blang/latex
            #apk-user
        '';

        podmanCreateImage = pkgsAllowUnfree.writeShellScriptBin "podman-create-image" ''
          TAG='3.13.0'
          BASE_IMAGE='docker.io/library/alpine:'"$TAG"
          CONTAINER='alpine-container-to-commit'
          IMAGE='alpine-user-with-sudo'

          podman \
          rm \
          --force \
          --ignore \
          "$CONTAINER"

          podman \
          run \
          --interactive=true \
          --name="$CONTAINER" \
          --tty=false \
          --rm=false \
          --user=0 \
          "$BASE_IMAGE" \
          sh -c 'apk add --no-cache shadow sudo && groupadd --gid 12345 ada_group && useradd --create-home --no-log-init --uid 6789 --gid ada_group ada_user && apk del shadow'

          #--change ENTRYPOINT=entrypoint.sh \
          ID=$(podman \
          commit \
          "$CONTAINER" \
          "$IMAGE":"$TAG")

          podman \
          rm \
          --force \
          --ignore \
          "$CONTAINER"
        '';

        testsApkUser = pkgsAllowUnfree.writeShellScriptBin "apk-user" ''
          #set -x
          TAG='3.13.0'
          BASE_IMAGE='docker.io/library/alpine':"$TAG"
          IMAGE='localhost/alpine-user-with-sudo':"$TAG"

          podman-create-if-not-existis "$IMAGE"

          echo 'Entering in the alpine OCI image...'
          podman \
          run \
          --interactive=true \
          --tty=true \
          --rm=true \
          --user=0 \
          "$IMAGE" \
          sh
        '';
      in
      {

        # For FREE packages use:
        packages.podman = import ./podman.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        #packages.podman = import ./podman.nix {
        #  pkgs = pkgsAllowUnfree;
        #};

        defaultPackage = self.packages.${system}.podman;

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [

            # This comes from pkgsAllowUnfree
            conmon
            libcap
            podman
            ripgrep
            runc
            shadow
            slirp4netns

            # This comes from this flake it self
            myScript
            podmanSetupScript
            cleanPodmanSetup
            clearPodmanCreatedContainersAndMore
            dockerCompat

            podmanCreateImage
            podmanCreateIfNotExistis
            testsApkUser
            messCapabilities
            podmanWrapper
          ];
          shellHook = ''
            # Fix a issue with the ~/tmp filesystem size
            export TMPDIR=/tmp

            echo "Entering the nix devShell"

            alias pc='podman-clear'
            alias pi='podman images'

            podman-wrapper

          '';
        };
      });
}
