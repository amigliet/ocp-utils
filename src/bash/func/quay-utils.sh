
# From Web UI everything is straightforward.
# From CLI: when in need, source this file and avoid typing these commands every time.

# Note: the function's names are too long, but at least they are intuitive.

function quay_get_config_editor_secret() {
  oc get quayregistries.quay.redhat.com \
    -o jsonpath="{.items[0].status.configEditorCredentialsSecret}{'\n'}"
}

function quay_get_config_editor_password() {
  local QUAY_CONFIG_EDITOR_SECRET="$( quay_get_config_editor_secret )"
  local QUAY_NAMESPACE="${1:-$(oc project -q)}"

  oc get secret/"$QUAY_CONFIG_EDITOR_SECRET" -n "$QUAY_NAMESPACE" \
    -o template='{{ .data.password | base64decode }}' ; echo
}

function quay_get_config_editor_password_xclip() {
  quay_get_config_editor_password | xclip
}

function quay_get_config_bundle_secret() {
  oc get quayregistries.quay.redhat.com \
    -o jsonpath="{.items[0].spec.configBundleSecret}{'\n'}"
}

function quay_get_database_secret() {
  local DB_DEPLOYMENT="$(oc get deployment | awk '/quay-database/ { print $1 }')"
  oc get deployment/$DB_DEPLOYMENT \
    -o jsonpath="{.spec.template.spec.containers[0].env[0].valueFrom.secretKeyRef.name}{'\n'}"
}

function quay_extract_config_bundle_secret() {
  local QUAY_NAMESPACE="${1:-$(oc project -q)}"
  local QUAY_CURR_CONFIG_BUNDLE="$( quay_get_config_bundle_secret )"

  local -r QUAY_TMPDIR="$(mktemp -d)"
  printf '%s\n' "$QUAY_TMPDIR"

  oc extract secret/"$QUAY_CURR_CONFIG_BUNDLE" -n "$QUAY_NAMESPACE" --to="$QUAY_TMPDIR"
}

function quay_dump_database() {

  local DB_SECRET="$( quay_get_database_secret )"

  local PSQL_USER="$(oc get secret/"$DB_SECRET" -o template='{{ index .data "database-username" | base64decode }}')"
  local PSQL_DB="$(oc get secret/"$DB_SECRET" -o template='{{ index .data "database-name" | base64decode }}')"

  local DB_POD="$(oc get pods | awk '/quay-database/ { print $1 }')"

  local QUAY_BACKUP_DIR="/var/tmp/quay-backup/db"
  local QUAY_BACKUP_FILE="$QUAY_BACKUP_DIR/$PSQL_DB-$(date +%Y%m%d-%H%M%S).sql"

  if [ ! -d "$QUAY_BACKUP_DIR" ]; then
    mkdir -p "$QUAY_BACKUP_DIR"
  fi

  oc exec "$DB_POD" -- \
      pg_dump -U "$PSQL_USER" -h localhost "$PSQL_DB" > "$QUAY_BACKUP_FILE"

  echo "Created backup file: $QUAY_BACKUP_FILE"
}
