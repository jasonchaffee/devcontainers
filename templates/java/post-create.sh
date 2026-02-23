#!/bin/bash
# post-create.sh - Runs ONCE after devcontainer creation
set -e

echo "Setting up devcontainer..."

# Git safe.directory — workspace is owned by a different UID than vscode
sudo git config --system --add safe.directory '*'

# Cache directories
sudo mkdir -p ~/.cache
sudo chown -R "$(whoami)" ~/.cache
mkdir -p ~/.cache/zsh ~/.cache/zsh-utils

# =============================================================================
# Verify installed tools
# =============================================================================

echo ""
echo "Tool versions:"
gcloud --version 2>/dev/null | head -1
kubectl version --client 2>/dev/null | head -1
helm version 2>/dev/null
java --version 2>/dev/null | head -1

echo ""
echo "Dev container ready!"
