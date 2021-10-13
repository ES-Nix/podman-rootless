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
          ];

          # inputsFrom = [ self.defaultPackage ];
          # inputsFrom = builtins.attrValues self.packages.${system};

          shellHook = ''
            # TODO: document this
            export TMPDIR=/tmp
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

