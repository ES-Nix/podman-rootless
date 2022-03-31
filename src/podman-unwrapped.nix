{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "podman";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    podman-unwrapped
  ]
  ++
  (if pkgs.stdenv.isDarwin then [ ] else [ conmon runc slirp4netns ])
  ++
  [
    (import ./utils/setcap-fix-unwrapped.nix { inherit pkgs; })
    (import ./utils/podman-minimal-setup-registries-and-policy.nix { inherit pkgs; })
  ];

  src = builtins.path { path = ./.; name = "podman-unwrapped"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out
    ls -al $out/

     # Note that the name is changed to just podman
    install \
    -m0755 \
    $out/podman-unwrapped.sh \
    -D \
    $out/bin/podman

    patchShebangs $out/bin/podman

    wrapProgram $out/bin/podman \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
