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
        packages.${name} = import ./src/podman.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        # `nix build .#podman-minimal-setup-registries-and-policy`
        packages.podman-minimal-setup-registries-and-policy = import ./src/utils/podman-minimal-setup-registries-and-policy.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        # `nix build .#setcap-fix`
        packages.setcap-fix = import ./src/utils/setcap-fix.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        defaultPackage = packages.${name};

        # `nix develop`
        devShell = pkgs.mkShell {

          buildInputs = with pkgs; [
            nixpkgs-fmt
            shellcheck
            findutils

            self.packages.${system}.${name}
          ];

          # inputsFrom = [ self.defaultPackage ];
          # inputsFrom = builtins.attrValues self.packages.${system};

          shellHook = ''
            # TODO: document this
            export TMPDIR=/tmp

            # find . -type f -iname '*.nix' -exec nixpkgs-fmt {} \;
          '';
        };

        # `nix run`
        apps.${name} = flake-utils.lib.mkApp {
          inherit name;
          drv = packages.${name};
        };

        # `nix run .#podman-minimal-setup-registries-and-policy`
        apps.podman-minimal-setup-registries-and-policy = flake-utils.lib.mkApp {
          name = "podman-minimal-setup-registries-and-policy";
          drv = packages.podman-minimal-setup-registries-and-policy;
        };

        # `nix run .#setcap-fix`
        apps.setcap-fix = flake-utils.lib.mkApp {
          name = "setcap-fix";
          drv = packages.setcap-fix;
        };

        defaultApp = apps.${name};

        checks = {
          nixpkgsFmt = pkgs.runCommand "check-nix-format" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            mkdir $out #success
          '';

          codeSpell = pkgs.runCommand "codespell"
            {
              buildInputs = with pkgs; [ findutils codespell ];
            } ''
            find ${./.} -type f -print0 | xargs -0 -n1 codespell -d -q 3 -

            mkdir $out #success
          '';

          shellCheck = pkgs.runCommand "shellcheck"
            {
              buildInputs = with pkgs; [ findutils shellcheck ];
            } ''

            find ${./.} -type f -iname '*.sh' -print0 | xargs -0 -n1 shellcheck

            mkdir $out #success
          '';

          build = self.defaultPackage.${system};

          setcap-fix = packages.setcap-fix;
          podman-minimal-setup-registries-and-policy = packages.podman-minimal-setup-registries-and-policy;
        };

        # hydraJobs = self.packages;
        # https://www.tweag.io/blog/2020-07-31-nixos-flakes/
        # hydraJobs.build = self.defaultPackage.${system};
      });
}

