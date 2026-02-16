#!/bin/bash
set -e

INSTALL="${INSTALL:-true}"
VERSION="${VERSION:-latest}"

# Skip installation if install=false
if [ "${INSTALL}" = "false" ]; then
    echo "Skipping Google Gemini CLI installation (install=false)"
    exit 0
fi

echo "Installing Google Gemini CLI..."

# npm is provided by the node feature via dependsOn

# Install Gemini CLI via npm
if [ "${VERSION}" = "latest" ]; then
    npm install -g @google/gemini-cli
else
    npm install -g "@google/gemini-cli@${VERSION}"
fi

echo "Google Gemini CLI installed successfully!"
