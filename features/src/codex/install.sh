#!/bin/bash
set -e

INSTALL="${INSTALL:-true}"
VERSION="${VERSION:-latest}"

# Skip installation if install=false
if [ "${INSTALL}" = "false" ]; then
    echo "Skipping OpenAI Codex CLI installation (install=false)"
    exit 0
fi

echo "Installing OpenAI Codex CLI..."

# npm is provided by the node feature via dependsOn

# Install Codex CLI
if [ "${VERSION}" = "latest" ]; then
    npm install -g @openai/codex
else
    npm install -g "@openai/codex@${VERSION}"
fi

echo "Codex CLI installed successfully!"
