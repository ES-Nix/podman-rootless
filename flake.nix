{
  description = "This is a nix flake podman rootless package";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgsAllowUnfree = import nixpkgs {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };

      in
      {

        packages.podman = import ./podman.nix {
          pkgs = pkgs;
        };

        defaultPackage = import ./podman.nix {
          pkgs = pkgs;
        };

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
            neovim
            self.defaultPackage.${system}
            self.packages.${system}.podman
          ];
          shellHook = ''
            echo "Entering the nix devShell"
            script-exemple
            fsh-podman-rootless-env
            #podman-setup-script
            #podman-capabilities
          '';
        };
      });
}
