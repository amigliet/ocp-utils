#!/bin/bash

function update_oc_client() {

  local BIN_DIR="$HOME/.local/bin"
  local OC_ARCHIVE="/tmp/openshift-client-linux.tar.gz"

  local OC_ARCHIVE_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz"
  local OC_SHA256_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/sha256sum.txt"

  echo "Downloading the archive into $OC_ARCHIVE.."
  curl --progress-bar --show-error --output "$OC_ARCHIVE" "$OC_ARCHIVE_URL"

  local RSHA="$(curl -s $OC_SHA256_URL | awk '/openshift-client-linux/ { print $1 }')"
  local LSHA="$(sha256sum $OC_ARCHIVE | awk '{ print $1 }')"

  if [ "$RSHA" == "$LSHA" ]; then
    echo -n "Check SHA256: good. "
  else
    echo "Check SHA256: wrong, abort."
    return
  fi

  if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR";
  fi
  tar xf "$OC_ARCHIVE" -C "$BIN_DIR" oc kubectl
  echo "Done."
}

# main
if which curl 1>/dev/null 2>&1; then
  update_oc_client
else
  echo "$(basename $0): curl command not found"
fi

