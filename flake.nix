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

        podmanCapabilities = pkgsAllowUnfree.writeShellScriptBin "podman-capabilities" ''
          #!${nixpkgs.legacyPackages.${system}.stdenv.shell}
          
          # TODO: add a conditional here to run this mesage only when 
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

        podmanClearConfigFiles = pkgsAllowUnfree.writeShellScriptBin "podman-clear-config-files" ''
          #!${pkgsAllowUnfree.runtimeShell}
  
           rm --force --verbose ~/.config/containers/policy.json
           rm --force --verbose ~/.config/containers/registries.conf
        '';

        podmanClearItsData = pkgsAllowUnfree.writeShellScriptBin "podman-clear-its-data" ''
          #!${pkgsAllowUnfree.runtimeShell}
    
          # TODO: it need tests!
          podman ps --all --quiet | xargs --no-run-if-empty podman stop \
          && podman ps --all --quiet | xargs --no-run-if-empty podman rm --force\
          && podman images --quiet | xargs --no-run-if-empty podman rmi --force \
          && podman container prune --force \
          && podman images --quiet | podman image prune --force \
          && podman network ls --quiet | xargs --no-run-if-empty podman network rm \
          && podman volume ls --quiet | xargs --no-run-if-empty podman volume prune
        '';

        # TODO: it does not work
        testsPodmanInstall = pkgsAllowUnfree.writeShellScriptBin "tests-podman-install" ''
          #!${pkgsAllowUnfree.runtimeShell}

           touch $out
           cp ${./tests.sh} $out/${./tests.sh}
           .$out/tests.sh
        '';

      in
      {
        # For FREE packages use:
        #packages.podman = import ./podman.nix {
        #    pkgs = nixpkgs.legacyPackages.${system};
        #};

        packages.mypodman = import ./podman.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };
        defaultPackage = self.packages.${system}.mypodman;

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
            conmon
            podman
            runc
            shadow
            slirp4netns
            podmanCapabilities
            podmanSetupScript # config files in here
            podmanClearConfigFiles
            #testsPodmanInstall # not working
            podmanClearItsData
            dockerCompat
            #mypodman.defaultPackage.${system}
            self.defaultPackage.${system}
          ];
          shellHook = ''
            #echo "Entering the nix devShell"
            podman-setup
            podman-capabilities
            test_script
            compleInstallPodman
          '';

        };

      });

}
