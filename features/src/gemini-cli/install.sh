#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Google Gemini CLI (version: ${VERSION})..."

# npm is provided by the node feature via dependsOn
# Use --prefer-offline to speed up installation when packages are cached
# Use --no-audit to skip vulnerability check (faster)
# Use --no-fund to skip funding messages (faster)
NPM_OPTS="--prefer-offline --no-audit --no-fund"

# Install Gemini CLI via npm
if [ "${VERSION}" = "latest" ]; then
    npm install -g ${NPM_OPTS} @google/gemini-cli
else
    npm install -g ${NPM_OPTS} "@google/gemini-cli@${VERSION}"
fi

echo "Google Gemini CLI installed successfully!"
