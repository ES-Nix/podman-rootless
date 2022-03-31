{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "podman";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [

  ]
  ++
  # Here are some magic stuff
  # I am not sure if it is a good idead, may be a default warning about it?
  (if pkgs.stdenv.isDarwin then [ ] else [ shadow cni-plugins podman ])
  ++
  [
    (import ./utils/setcap-fix.nix { inherit pkgs; })
    (import ./utils/podman-minimal-setup-registries-and-policy.nix { inherit pkgs; })
  ];

  src = builtins.path { path = ./.; name = "podman"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out
    ls -al $out/

    install \
    -m0755 \
    $out/podman.sh \
    -D \
    $out/bin/podman

    patchShebangs $out/bin/podman

    wrapProgram $out/bin/podman \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
