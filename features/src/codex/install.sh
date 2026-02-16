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
# Use --prefer-offline to speed up installation when packages are cached
# Use --no-audit to skip vulnerability check (faster)
# Use --no-fund to skip funding messages (faster)
NPM_OPTS="--prefer-offline --no-audit --no-fund"

# Install Codex CLI
if [ "${VERSION}" = "latest" ]; then
    npm install -g ${NPM_OPTS} @openai/codex
else
    npm install -g ${NPM_OPTS} "@openai/codex@${VERSION}"
fi

echo "Codex CLI installed successfully!"
