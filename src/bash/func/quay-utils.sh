
# From Web UI everything is straightforward.
# From CLI: when in need, source this file and avoid typing these commands every time.

# Note: the function's names are too long, but at least they are intuitive.

function quay_get_config_editor_secret() {
  oc get quayregistries.quay.redhat.com -o jsonpath="{.items[0].status.configEditorCredentialsSecret}{'\n'}"
}

function quay_get_config_editor_password() {
  local QUAY_CONFIG_EDITOR_SECRET="$( quay_get_config_editor_secret )"
  local QUAY_NAMESPACE="${1:-$(oc project -q)}"

  oc get secret/"$QUAY_CONFIG_EDITOR_SECRET" -n "$QUAY_NAMESPACE" -o jsonpath='{.data.password}' | \
  base64 -d ; echo
}

function quay_get_config_editor_password_xclip() {
  local QUAY_CONFIG_EDITOR_SECRET="$( quay_get_config_editor_secret )"
  local QUAY_NAMESPACE="${1:-$(oc project -q)}"

  oc get secret/"$QUAY_CONFIG_EDITOR_SECRET" -n "$QUAY_NAMESPACE" -o jsonpath='{.data.password}' | \
  base64 -d | xclip
}

function quay_get_config_bundle_secret() {
  oc get quayregistries.quay.redhat.com -o jsonpath="{.items[0].spec.configBundleSecret}{'\n'}"
}

function quay_extract_config_bundle_secret() {
  local QUAY_NAMESPACE="${1:-$(oc project -q)}"
  local QUAY_CURR_CONFIG_BUNDLE="$( quay_get_config_bundle_secret )"

  readonly QUAY_TMPDIR="$(mktemp -d)"
  printf '%s\n' "$QUAY_TMPDIR"

  oc extract secret/"$QUAY_CURR_CONFIG_BUNDLE" -n "$QUAY_NAMESPACE" --to="$QUAY_TMPDIR"
}

