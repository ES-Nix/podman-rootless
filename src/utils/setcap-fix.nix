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

    ls -la "${pkgs.shadow}"/bin

    substituteInPlace $out/setcap-fix.sh \
      --replace "'newgidmap'" "${pkgs.shadow}/bin/newgidmap" \
      --replace "'newuidmap'" "${pkgs.shadow}/bin/newuidmap"

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
