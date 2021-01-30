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
                          conmon
                          podman
                          runc
                          shadow
                          slirp4netns
                     ];
        };

      });

}
