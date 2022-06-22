{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "setcap-fix";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
    gnugrep
    which

    mount
    ripgrep
    sed
  ]
  ++
  # Here are some magic stuff.
  # I am not sure if it is a good idea, may be a default warning about it?
  (if pkgs.stdenv.isDarwin then [ ] else [ libcap ]);

  src = builtins.path { path = ./.; name = "setcap-fix"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out
    # ls -al $out/

    aux_newgidmap="${
        (
        if !pkgs.stdenv.isDarwin
        then "${pkgs.shadow}/bin/newgidmap"
        else "")
    }"

    aux_newuidmap="${
        (
        if !pkgs.stdenv.isDarwin
        then "${pkgs.shadow}/bin/newuidmap"
        else "")
    }"
    substituteInPlace $out/setcap-fix.sh \
      --replace "'newgidmap'" "$aux_newgidmap" \
      --replace "'newuidmap'" "$aux_newuidmap"

    install \
    -m0755 \
    $out/setcap-fix.sh \
    -D \
    $out/bin/setcap-fix

    patchShebangs $out/bin/setcap-fix

    wrapProgram $out/bin/setcap-fix \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
