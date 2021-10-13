{ pkgs ? import <nixpkgs> { } }:
let
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

  # Provides a fake "docker" binary mapping to podman
  dockerPodmanCompat = pkgs.runCommandNoCC "docker-podman-compat" { } ''
    mkdir --parent $out/bin
    ln --symbolic ${pkgs.podman}/bin/podman $out/bin/docker
  '';

  podmanClearConfigFiles = pkgs.writeShellScriptBin "podman-clear-config-files" ''
    rm --force --verbose ~/.config/containers/policy.json
    rm --force --verbose ~/.config/containers/registries.conf
  '';

  podmanClearItsData = pkgs.writeShellScriptBin "podman-clear-its-data" ''
    # TODO: it needs tests!
    podman ps --all --quiet | xargs --no-run-if-empty podman rm --force \
    && podman images --quiet | xargs --no-run-if-empty podman rmi --force \
    && podman container prune --force \
    && podman images --quiet | podman image prune --force \
    && podman network ls --quiet | xargs --no-run-if-empty podman network rm \
    && podman volume prune --force
    podman pod list --quiet | xargs --no-run-if-empty podman pod rm --force
  '';

  podmanWrapper = pkgs.writeShellScriptBin "podman" ''
    ${podmanSetupScript}/bin/podman-setup-script
    ${pkgs.podman}/bin/podman "$@"
  '';

in
pkgs.stdenv.mkDerivation {
  name = "podman-rootless-derivation";
  buildInputs = with pkgs; [
    podmanClearItsData
    podmanWrapper
    podmanSetupScript
    # dockerPodmanCompat
  ];


  # buildPhase = dockerPodmanCompat;

  installPhase = ''
    mkdir --parent $out/bin

    # install -t $out/bin ${pkgs.podman}/bin/podman
    
    install -t $out/bin ${podmanSetupScript}/bin/podman-setup-script
    install -t $out/bin ${podmanClearConfigFiles}/bin/podman-clear-config-files
    install -t $out/bin ${podmanClearItsData}/bin/podman-clear-its-data
    install -t $out/bin ${podmanWrapper}/bin/podman
  '';

  phases = [ "buildPhase" "installPhase" "fixupPhase" ];

}
