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


        myScript =  pkgsAllowUnfree.writeShellScriptBin "extraPodman" ''
          set -x
          # TODO: add a conditional here to run this mesage only when
          # needs a sudo call, i mean, only the first time problably.
          # No call for sudo is neede after de first time (in most cases)
          # We should check for the actual capabilitie and if they are 
          # the ones that podman needs skip the sudo calls.

          NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
          NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

          echo 'Fixing capabilities. It requires sudo, sorry!'
          if ! command -v sudo &> /dev/null
          then
            echo 'Well, sudo is NOT in the PATH'
            echo 'Printing the PATH:' "$PATH"
            exit 1
          fi

          if ! (( getcap "$NEWUIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' || getcap "$NEWGIDMAP" | rg --quiet --case-sensitive --fixed-strings 'cap_setuid=ep' )); then
            echo 'Calling sudo to setcap of:' "$NEWUIDMAP"
            sudo setcap cap_setuid+ep "$NEWUIDMAP"
            sudo setcap cap_setgid+ep "$NEWGIDMAP"
          fi

       '';

        messCapabilities =  pkgsAllowUnfree.writeShellScriptBin "mess-capabilities" ''
          set -x
          # TODO: add a conditional here to run this mesage only when
          # needs a sudo call, i mean, only the first time problably.
          # No call for sudo is neede after de first time (in most cases)
          # We should check for the actual capabilitie and if they are
          # the ones that podman needs skip the sudo calls.

          NEWUIDMAP=$(readlink --canonicalize $(which newuidmap))
          NEWGIDMAP=$(readlink --canonicalize $(which newgidmap))

          echo 'Fixing capabilities. It requires sudo, sorry!'
          if ! command -v sudo &> /dev/null
          then
            echo 'Well, sudo is NOT in the PATH'
            echo 'Printing the PATH:' "$PATH"
            exit 1
          fi

          echo 'Running setcap -r'
          sudo setcap -r "$NEWUIDMAP"
          sudo setcap -r "$NEWGIDMAP"

          echo 'Running getcap'
          sudo getcap "$NEWUIDMAP"
          sudo getcap "$NEWGIDMAP"
       '';


  # Provides a script that copies required files to ~/
  podmanSetupScript = let
    registriesConf = pkgsAllowUnfree.writeText "registries.conf" ''
      [registries.search]
      registries = ['docker.io']
      [registries.block]
      registries = []
    '';
  in pkgsAllowUnfree.writeShellScriptBin "podman-setup" ''
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
  dockerCompat = pkgsAllowUnfree.runCommandNoCC "docker-podman-compat" {} ''
    mkdir -p $out/bin
    ln -s ${pkgsAllowUnfree.podman}/bin/podman $out/bin/docker
  '';

  cleanPodmanSetup = pkgsAllowUnfree.writeShellScriptBin "clear-podman-setup" ''
    #!${pkgsAllowUnfree.runtimeShell}
  
     rm --force --verbose ~/.config/containers/policy.json
     rm --force --verbose ~/.config/containers/registries.conf
   
  '';

  clearPodmanCreatedContainersAndMore = pkgsAllowUnfree.writeShellScriptBin "podman-clear" ''
    #!${pkgsAllowUnfree.runtimeShell}
    
    # TODO: it need tests!
    podman ps --all --quiet | xargs --no-run-if-empty podman stop \
    && podman ps --all --quiet | xargs --no-run-if-empty podman rm --force\
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

      if podman images | rg --quiet --case-sensitive --fixed-strings "$IMAGE"; then
        echo 'Creating image'
        podman-create-image
      fi
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
        BASE_IMAGE='localhost/alpine-user-with-sudo':"$TAG"


        podman-create-if-not-existis "$BASE_IMAGE"

        podman \
        run \
        --interactive=true \
        --tty=true \
        --rm=true \
        --user=0 \
        "$BASE_IMAGE" \
        sh
  '';
      in
      {

        # For FREE packages use:
        #packages.podman = import ./podman.nix {
        #    pkgs = nixpkgs.legacyPackages.${system};
        #};

        #packages.podman = import ./podman.nix {
        #  pkgs = pkgsAllowUnfree;
        #};

        #defaultPackage = self.packages.${system}.podman;

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
                                     
                                         conmon
                                         libcap
                                         podman
                                         ripgrep
                                         runc
                                         shadow
                                         slirp4netns                          
                                         myScript
                                         podmanSetupScript
                                         cleanPodmanSetup
                                         clearPodmanCreatedContainersAndMore

                                         podmanCreateImage
                                         podmanCreateIfNotExistis
                                         testsApkUser
                                         messCapabilities
                          ];
        shellHook = ''
           echo "Entering the nix devShell"
           podman-setup
           extraPodman
           #apk-user

         '';

        };

      });

}
