
# Simple prompt function for k8s/ocp
__k8s_ps1() {

  # An implemetation using kubectl config get-contexts might be
  # more straightforward, but this one is faster and easy enough

  k8s_prompt_pattern="${1:-}"

  local kube_config="${KUBECONFIG:-$HOME/.kube/config}"

  if test ! -f "$kube_config"; then
    printf '%s' ""
    return
  fi

  case "$k8s_prompt_pattern" in
    f|full)
      awk -F/ '/^current-context:/ {
        sub("current-context: ","");
        printf("%s|%s|%s", $3, $2, $1) }' "$kube_config"
      ;;
    l|long)
      awk -F/ '/^current-context:/ {
        sub("current-context: ","");
        printf("%s|%s", $3, $1) }' "$kube_config"
      ;;
    u|username)
      awk -F/ '/^current-context:/ {
        sub("current-context: ","");
        printf("%s", $3) }' "$kube_config"
      ;;
    e|endpoint)
      awk -F/ '/^current-context:/ {
        sub("current-context: ","");
        printf("%s", $2) }' "$kube_config"
      ;;
    n|namespace)
      awk -F/ '/^current-context:/ {
        sub("current-context: ","");
        printf("%s", $1) }' "$kube_config"
      ;;
    *)
      awk -F/ '/^current-context:/ {
        sub("current-context: ","");
        printf("%s|%s", $3, $1) }' "$kube_config"
      ;;
  esac

}

