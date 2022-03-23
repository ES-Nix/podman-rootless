{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "setcap-fix-unwrapped";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
    gnugrep
    mount
    which
  ]
  ++
  # Here are some magic stuff.
  # I am not sure if it is a good idea, may be a default warning about it?
  (if pkgs.stdenv.isDarwin then [ ] else [ libcap ]);

  src = builtins.path { path = ./.; name = "setcap-fix-unwrapped"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out
    ls -al $out/

    install \
    -m0755 \
    $out/setcap-fix-unwrapped.sh \
    -D \
    $out/bin/setcap-fix-unwrapped

    patchShebangs $out/bin/setcap-fix-unwrapped

    wrapProgram $out/bin/setcap-fix-unwrapped \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
