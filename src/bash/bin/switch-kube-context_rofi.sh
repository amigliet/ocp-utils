#!/bin/bash

# Switch easily Kubernetes/OpenShift context.
# This script is meant to be used with i3wm+rofi.

function _rofi_menu_printf() {
  kubectl config get-contexts | \
  awk 'NR==1 { next; } !/^*/{ printf("  %s\n", $1); next; } { printf("%s %s\n", $1,$2); }'
}

function _rofi() {
  rofi -lines 10 -columns 1 -i -dmenu "$@" -p "kube"
}

KUBE_CONTEXT="$( _rofi_menu_printf | _rofi | awk '!/^*/{ print $1; next; } { print $2; }' )"

if ! which kubectl 1>/dev/null 2>&1; then
  i3-nagbar --type error --message "kubectl: command not found"
  exit 1
fi

if [ -n "$KUBE_CONTEXT" ]; then
  kubectl config use-context "$KUBE_CONTEXT" 1>/dev/null 2>&1
fi

