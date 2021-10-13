{
  description = "This is a nix flake podman rootless wrapper";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs {
          inherit system;
        };

        # Provides a script that copies required files to ~/
        podmanSetupScript =
          let
            registriesConf = pkgs.writeText "registries.conf" ''
              [registries.search]
              registries = ['docker.io']
              [registries.block]
              registries = []
            '';
          in
          pkgs.writeShellScriptBin "podman-setup-script" ''
            if [ "$(id --user)" = "0" ]; then
              # Dont overwrite customised configuration
              if ! test -f /etc/containers/policy.json; then
                install -Dm555 ${pkgs.skopeo.src}/default-policy.json /etc/containers/policy.json
              fi

              if ! test -f /etc/containers/registries.conf; then
                install -Dm555 ${registriesConf} /etc/containers/registries.conf
              fi

            else
              # Dont overwrite customised configuration
              if ! test -f ~/.config/containers/policy.json; then
                install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
              fi

              if ! test -f ~/.config/containers/registries.conf; then
                install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
              fi
            fi
          '';
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
            # TODO: document this
            export TMPDIR=/tmp
            podman-setup-script     
          '';
        };

        checks = {
          nixpkgs-fmt = pkgs.runCommand "check-nix-format" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            mkdir $out #sucess
          '';

          build = self.defaultPackage.${system};
        };

      });
}

