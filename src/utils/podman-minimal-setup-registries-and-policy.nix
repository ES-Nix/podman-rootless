{ pkgs ? import <nixpkgs> { } }:
let

  # Provides a script that copies required files to ~/
  #
  #
  podmanSetupMinimalRegistriesAndPolicy =
    let
      registriesConf = pkgs.writeText "registries.conf" ''
        [registries.search]
        registries = ['docker.io']
        [registries.block]
        registries = []
      '';
    in
    pkgs.writeShellScriptBin "podman-minimal-setup-registries-and-policy" ''
      if [ "$(${pkgs.coreutils}/bin/id -u)" = "0" ]; then
        # Dont overwrite customised configuration
        if ! test -f /etc/containers/policy.json; then
          ${pkgs.coreutils}/bin/install -Dm555 ${pkgs.skopeo.src}/default-policy.json /etc/containers/policy.json
        fi

        if ! test -f /etc/containers/registries.conf; then
          ${pkgs.coreutils}/bin/install -Dm555 ${registriesConf} /etc/containers/registries.conf
        fi

      else
        # Dont overwrite customised configuration
        if ! test -f ~/.config/containers/policy.json; then
          ${pkgs.coreutils}/bin/install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
        fi

        if ! test -f ~/.config/containers/registries.conf; then
          ${pkgs.coreutils}/bin/install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
        fi
      fi
    '';
in
pkgs.stdenv.mkDerivation rec {
  name = "podman-minimal-setup-registries-and-policy";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [ ];

  # src = builtins.path { path = ./.; name = "podman-minimal-setup-registries-and-policy"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp "${podmanSetupMinimalRegistriesAndPolicy}"/bin/podman-minimal-setup-registries-and-policy \
    $out/bin/podman-minimal-setup-registries-and-policy

    wrapProgram $out/bin/podman-minimal-setup-registries-and-policy \
      --prefix PATH : "${ pkgs.lib.makeBinPath [ podmanSetupMinimalRegistriesAndPolicy ] }"
  '';

}
