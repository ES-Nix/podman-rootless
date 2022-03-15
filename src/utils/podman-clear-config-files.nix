{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
          name = "setcap-fix";
          buildInputs = with pkgs; [ stdenv ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          propagatedNativeBuildInputs = with pkgs; [
            bash
            coreutils
            gnugrep
            libcap
            which
          ];

          src = builtins.path { path = ./.; name = "setcap-fix"; };
          phases = [ "installPhase" ];

          unpackPhase = ":";

          installPhase = ''
            mkdir -p $out/bin

            cp -r "${src}"/* $out
            ls -al $out/

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
