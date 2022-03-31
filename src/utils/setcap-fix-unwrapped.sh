#!/usr/bin/env sh

# set -x


get_full_path_of_new_user_or_group_id_map() {

  BIN_NAME_TO_FIND_FULL_PATH=$1

  # TODO: test if it breaks if it is changed to shellchek's recomendation
  # shellcheck disable=SC2284
  if "$BIN_NAME_TO_FIND_FULL_PATH" == "newgidmap" >/dev/null 2>&1; then
    echo '/run/wrappers/bin/newgidmap'
    exit 0
  fi

  # TODO: test if it breaks if it is changed to shellchek's recomendation
  # shellcheck disable=SC2284
  if "$BIN_NAME_TO_FIND_FULL_PATH" == "newuidmap" >/dev/null 2>&1; then
    echo '/run/wrappers/bin/newuidmap'
    exit 0
  fi

  echo 'The BIN_NAME_TO_FIND_FULL_PATH is neither: /run/wrappers/bin/newuidmap nor /run/wrappers/bin/newuidmap'
}

__sudo(){
  # I have seen this patter in bash scripts.
  # All calls to `sudo` must be done using this horrible named
  # function!
  sudo "$@"
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
    # shellcheck disable=SC2086
    chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"
  else
    if __sudo --version >/dev/null 2>&1; then
      # echo "sudo was found in PATH, trying to setcap and chmod for newuidmap"

      # shellcheck disable=SC2086
      __sudo chmod $VERBOSE "$VALUE_TO_CHMOD" "$FULL_BINARY_PATH"

#      echo "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
#      getcap "$FULL_BINARY_PATH"
      # shellcheck disable=SC2086
      __sudo setcap $VERBOSE "$CAPABILITIE_TO_SET" "$FULL_BINARY_PATH"
    else
      echo 'You are not either root or have sudo. Failed to install.'
      exit 100
    fi
  fi
}

check_if_nix_store_is_writable() {
  # It is useful for NixOS systems in that
  # the `/nix` is readonly.
#  if ! mount | rg -q /nix/; then
#    #echo 'Not able to write to /nix. Failed to install podman.'
#    if
#    exit 101
#  fi
  exit 0
}


if_the_podman_required_permissions_are_not_the_needed_ones_try_fix_it() {

  NEW_U_OR_G_ID_MAP="$1"
  CAP_SET_U_OR_G_ID="$2"

  if ! getcap "$(get_full_path_of_new_user_or_group_id_map "${NEW_U_OR_G_ID_MAP}")" | grep -q "${CAP_SET_U_OR_G_ID}"; then
    # check_if_nix_store_is_writable
    setcap_chmod "${CAP_SET_U_OR_G_ID}" "$(get_full_path_of_new_user_or_group_id_map "${NEW_U_OR_G_ID_MAP}")"
  fi
}

if_binary_not_in_path_raise_an_error() {
  if ! command -v "$1" 1> /dev/null 2> /dev/null; then
    echo 'The binary ' "$1" 'was not found in PATH'
    exit 42
  fi
}

###


# CAP_SETUID='cap_setuid=+ep'
# CAP_SETGID='cap_setgid=+ep'


# if_binary_not_in_path_raise_an_error 'newuidmap'
# if_binary_not_in_path_raise_an_error 'newgidmap'

#if_the_podman_required_permissions_are_not_the_needed_ones_try_fix_it 'newuidmap' "${CAP_SETUID}"
#if_the_podman_required_permissions_are_not_the_needed_ones_try_fix_it 'newgidmap' "${CAP_SETGID}"


# Uncomment it when debug
# echo '.'
# echo "$(get_full_path_of_new_user_or_group_id_map newuidmap)"
# stat "$(get_full_path_of_new_user_or_group_id_map newuidmap)"
# getcap "$(get_full_path_of_new_user_or_group_id_map newuidmap)"

# https://github.com/containers/podman/issues/2788#issuecomment-479972943
# https://stackoverflow.com/a/677212
