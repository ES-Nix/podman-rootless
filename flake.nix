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

        #packages.podman = import ./podman.nix {
        #  pkgs = pkgsAllowUnfree;
        #};

        #defaultPackage = self.packages.${system}.podman;

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
                                     
                                         conmon
                                         podman
                                         runc
                                         shadow
                                         slirp4netns                          
                                         myScript
                                         podmanSetupScript
                                         cleanPodmanSetup
                                         testsPodmanInstall
                                         clearPodmanCreatedContainersAndMore
                          ];
        shellHook = ''
           #echo "Entering the nix devShell"
           podman-setup
           extraPodman
         '';

        };

      });

}
