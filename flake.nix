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
          pkgs = nixpkgs.legacyPackages.${system};
        };

        defaultPackage = import ./podman.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.defaultPackage.${system}
            self.packages.${system}.podman
          ];
          shellHook = ''
            # TODO: it needs to be well documented!
            export TMPDIR=/tmp
            podman-capabilities
          '';
        };
      });
}
