#!/bin/bash

# Simple test for comparison

__k8s_ps1_kubectl() {
  kubectl config get-contexts 1>/dev/null 2>&1
}

__k8s_ps1_awk() {
  local kube_config="${KUBECONFIG:-$HOME/.kube/config}"

  if test ! -f "$kube_config"; then
    printf '%s' ""
    return
  fi

  awk -F/ '/^current-context:/ {
    sub("current-context: ","");
    printf("%s|%s|%s", $3, $2, $1) }' "$kube_config" 1>/dev/null
}

time __k8s_ps1_kubectl
time __k8s_ps1_awk

