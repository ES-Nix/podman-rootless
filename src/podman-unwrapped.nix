{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "podman-unwrapped";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    podman-unwrapped

    conmon
    runc
    slirp4netns
  ]
  ++
  # Here are some magic stuff
  # I am not sure if it is a good idead, may be a default warning about it?
  (if pkgs.stdenv.isDarwin then [ ] else [ shadow cni-plugins ])
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

    install \
    -m0755 \
    $out/podman-unwrapped.sh \
    -D \
    $out/bin/podman-unwrapped

    patchShebangs $out/bin/podman-unwrapped

    wrapProgram $out/bin/podman-unwrapped \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
