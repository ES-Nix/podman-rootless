#!/usr/bin/env sh

# set -x


full_path_newugidmap() {

    BIN_NAME_TO_FIND_FULL_PATH=$1
    if ! stat "$(which "$BIN_NAME_TO_FIND_FULL_PATH" 2> /dev/null)" >/dev/null 2>&1; then
      exit 100
    fi

    # echo "$BIN_NAME_TO_FIND_FULL_PATH"

    if readlink --canonicalize "$(which "$BIN_NAME_TO_FIND_FULL_PATH")" >/dev/null 2>&1; then
      echo "$(readlink --canonicalize "$(which "$BIN_NAME_TO_FIND_FULL_PATH")")"
      exit 0
    fi

    if stat "$(which "$BIN_NAME_TO_FIND_FULL_PATH")" >/dev/null 2>&1; then
      echo "$(which "$BIN_NAME_TO_FIND_FULL_PATH")"
      exit 0
    fi
}


setcap_chmod() {

  CAPABILITIE_TO_SET="$1"
  FULL_BINARY_PATH="$2"

  # The u+s also works
  VALUE_TO_CHMOD='4755'

  # echo "$CAPABILITIE_TO_SET"
  # echo "$FULL_BINARY_PATH"
  # VERBOSE="-v"

  if [ "$(id -u)" = "0" ]; then
    setcap "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
    chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"
  else
    if sudo --version >/dev/null 2>&1; then
      # echo "sudo was found in PATH, trying to setcap and chmod for newuidmap"

      sudo chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"

#      echo "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
#      getcap "$FULL_BINARY_PATH"
      sudo setcap $VERBOSE "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
    else
      echo 'You are not either root or have sudo. Failed to install.'
      exit 100
    fi
  fi
}

check_nix_store_writible() {
  if ! test -w /nix; then
    echo 'Not able to write to /nix. Failed to install podman.'
    exit 101
  fi
}

###


CAP_SETUID='cap_setuid=+ep'
CAP_SETGID='cap_setgid=+ep'

# https://github.com/containers/podman/issues/2788#issuecomment-479972943
# https://stackoverflow.com/a/677212
# if newuidmap >/dev/null 2>&1; then
# if stat $(which newuidmap 2> /dev/null) >/dev/null 2>&1; then
if command -v newuidmap &> /dev/null; then
  if ! getcap "$(full_path_newugidmap newuidmap)" | grep -q "$CAP_SETUID"; then
    check_nix_store_writible
    setcap_chmod "$CAP_SETUID" "$(full_path_newugidmap newuidmap)"
  fi
else # If newuidmap was not found try to install it!
  check_nix_store_writible
  # nix profile install nixpkgs#shadow
  setcap_chmod "$CAP_SETUID" "$(full_path_newugidmap newuidmap)"
  # Uncomment it when debug
# echo '.'
# echo "$(full_path_newugidmap newuidmap)"
# stat "$(full_path_newugidmap newuidmap)"
# getcap "$(full_path_newugidmap newuidmap)"
fi

#
if command -v newgidmap &> /dev/null; then
  if ! getcap "$(full_path_newugidmap newgidmap)" | grep -q "$CAP_SETGID"; then
    check_nix_store_writible
    setcap_chmod "$CAP_SETGID" "$(full_path_newugidmap newgidmap)"
  fi
else # If newgidmap was not found try to install it!
  check_nix_store_writible
  # nix profile install nixpkgs#shadow
  setcap_chmod "$CAP_SETGID" "$(full_path_newugidmap newgidmap)"
  # Uncomment it when debugging
#              echo '.'
#              echo $(full_path_newugidmap newgidmap)
#              stat $(full_path_newugidmap newgidmap)
#              ${pkgs.libcap}/bin/getcap $(full_path_newugidmap newgidmap)
fi
