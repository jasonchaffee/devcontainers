#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Bun (version: ${VERSION})..."

# Detect architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64|amd64) BUN_ARCH="x64" ;;
    aarch64|arm64) BUN_ARCH="aarch64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Resolve latest version from GitHub
if [ "${VERSION}" = "latest" ]; then
    VERSION=$(curl -fsSL https://api.github.com/repos/oven-sh/bun/releases/latest \
        | grep '"tag_name"' \
        | sed -E 's/.*"bun-v([^"]+)".*/\1/')
fi

echo "Resolved version: ${VERSION}"

# Download zip and extract binary
ZIP="bun-linux-${BUN_ARCH}.zip"
curl -fsSL "https://github.com/oven-sh/bun/releases/download/bun-v${VERSION}/${ZIP}" -o /tmp/bun.zip
unzip -q /tmp/bun.zip -d /tmp/bun-extract
install -m 755 "/tmp/bun-extract/bun-linux-${BUN_ARCH}/bun" /usr/local/bin/bun
rm -rf /tmp/bun.zip /tmp/bun-extract

echo "Bun installed successfully!"
bun --version
