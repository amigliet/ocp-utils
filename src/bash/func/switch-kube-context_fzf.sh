
function _fzf_kubectl_config_use-context() {
  kubectl config get-contexts | \
  awk 'NR==1 { next; } !/^*/{ print $1; next; } { print $2; }' | \
  fzf --bind 'enter:execute(kubectl config use-context {})+abort' \
      --layout=reverse --prompt="kube>"
}

alias kctx='_fzf_kubectl_config_use-context'

