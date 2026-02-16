#!/bin/bash
set -e

echo "Installing HTTP Tools..."

# Dependencies (curl, ca-certificates) provided by common-utils via dependsOn

# Detect architecture (cross-platform)
MACHINE_ARCH=$(uname -m)
case "${MACHINE_ARCH}" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${MACHINE_ARCH}"; exit 1 ;;
esac

if [ "${INSTALLXH}" = "true" ]; then
    echo "Installing xh..."
    # Get latest version
    XH_VERSION=$(curl -fsSL https://api.github.com/repos/ducaale/xh/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -z "$XH_VERSION" ]; then
        XH_VERSION="0.24.0"
    fi

    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL "https://github.com/ducaale/xh/releases/download/v${XH_VERSION}/xh-v${XH_VERSION}-aarch64-unknown-linux-musl.tar.gz" \
            | tar -xz --strip-components=1 -C /usr/local/bin/ "xh-v${XH_VERSION}-aarch64-unknown-linux-musl/xh"
    else
        curl -fsSL "https://github.com/ducaale/xh/releases/download/v${XH_VERSION}/xh-v${XH_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar -xz --strip-components=1 -C /usr/local/bin/ "xh-v${XH_VERSION}-x86_64-unknown-linux-musl/xh"
    fi
fi

echo "HTTP Tools installed successfully!"
