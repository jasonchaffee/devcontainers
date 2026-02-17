#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing OpenAI Codex CLI (version: ${VERSION})..."

# Install Node.js if not present
if ! command -v npm &> /dev/null; then
    echo "Node.js/npm not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y nodejs npm
    elif command -v apk &> /dev/null; then
        apk add --no-cache nodejs npm
    elif command -v dnf &> /dev/null; then
        dnf install -y nodejs npm
    elif command -v yum &> /dev/null; then
        yum install -y nodejs npm
    fi
fi

# npm is now guaranteed to be present
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
