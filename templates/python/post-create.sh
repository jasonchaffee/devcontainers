#!/bin/bash
# post-create.sh - Runs ONCE after devcontainer creation
set -e

echo "Setting up Python devcontainer..."

# Git safe.directory — workspace is owned by a different UID than vscode
sudo git config --system --add safe.directory '*'

# Cache directories
sudo mkdir -p ~/.cache
sudo chown -R "$(whoami)" ~/.cache
mkdir -p ~/.cache/zsh ~/.cache/zsh-utils

echo ""
echo "Tool versions:"
python3 --version 2>/dev/null || true
uv --version 2>/dev/null || true

echo ""
echo "Dev container ready!"
