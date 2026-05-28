#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Skaffold (version: ${VERSION})..."

# Detect architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64|amd64) SKAFFOLD_ARCH="amd64" ;;
    aarch64|arm64) SKAFFOLD_ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Resolve latest version from Google Cloud Storage
if [ "${VERSION}" = "latest" ]; then
    VERSION=$(curl -fsSL https://storage.googleapis.com/skaffold/releases/latest/VERSION | tr -d '[:space:]')
    VERSION="${VERSION#v}"
fi

echo "Resolved version: ${VERSION}"

URL="https://storage.googleapis.com/skaffold/releases/v${VERSION}/skaffold-linux-${SKAFFOLD_ARCH}"
echo "Downloading: ${URL}"
curl -fsSL "${URL}" -o /tmp/skaffold
install -m 755 /tmp/skaffold /usr/local/bin/skaffold
rm -f /tmp/skaffold

echo "Skaffold installed successfully!"
skaffold version
