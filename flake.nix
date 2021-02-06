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


        myScript =  pkgsAllowUnfree.writeShellScriptBin "compleInstallPodman" ''
          #!${nixpkgs.legacyPackages.${system}.stdenv.shell}
          echo 'The wrapper WWW!'


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
                          ];
        shellHook = ''
           echo "The hook"
           podman-setup
         '';

        };

      });

}
