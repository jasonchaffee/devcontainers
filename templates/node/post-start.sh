#!/bin/bash
# post-start.sh — Runs EVERY time the container starts

# Shell history
sudo chown -R vscode:vscode /commandhistory 2>/dev/null
touch /commandhistory/.zsh_history
ln -sf /commandhistory/.zsh_history ~/.zsh_history || true

# Kubeconfig: copy from read-only host mount, rewrite for devcontainer
# The host's ~/.kube is mounted read-only at ~/.kube-host. We copy the config
# to ~/.kube/config so kubectl sees it at the default path.
# Rancher Desktop's kubeconfig uses 127.0.0.1:6443 which doesn't resolve
# inside a container — rewrite to host.docker.internal and skip TLS verify
# (the server cert doesn't include that SAN).
if [ -f /.dockerenv ] && [ -f "$HOME/.kube-host/config" ]; then
    mkdir -p "$HOME/.kube"
    cp "$HOME/.kube-host/config" "$HOME/.kube/config"
    if grep -q '127.0.0.1:6443' "$HOME/.kube/config"; then
        kubectl config set-cluster rancher-desktop \
            --server=https://host.docker.internal:6443 \
            --insecure-skip-tls-verify=true 2>/dev/null || true
    fi
fi
