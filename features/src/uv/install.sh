#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing uv (version: ${VERSION})..."

# Install uv using the official standalone installer
# UV_INSTALL_DIR: install to /usr/local/bin so it's on PATH for all users
# UV_NO_MODIFY_PATH: don't modify shell profiles (devcontainer handles PATH)
export UV_INSTALL_DIR="/usr/local/bin"
export UV_NO_MODIFY_PATH=1

if [ "${VERSION}" = "latest" ]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    curl -LsSf "https://astral.sh/uv/${VERSION}/install.sh" | sh
fi

echo "uv $(uv --version) installed successfully!"
