#!/bin/bash
set -e

echo "Installing Terminal Extras..."

# Dependencies (curl, ca-certificates) provided by common-utils via dependsOn

ARCH=$(dpkg --print-architecture)

# Install apt-based tools
apt-get update

if [ "${INSTALLTMUX}" = "true" ]; then
    echo "Installing tmux..."
    apt-get install -y --no-install-recommends tmux
fi

if [ "${INSTALLBTOP}" = "true" ]; then
    echo "Installing btop..."
    apt-get install -y --no-install-recommends btop
fi

rm -rf /var/lib/apt/lists/*

# Install viddy (not in apt)
if [ "${INSTALLVIDDY}" = "true" ]; then
    echo "Installing viddy..."
    VIDDY_VERSION=$(curl -fsSL https://api.github.com/repos/sachaos/viddy/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL "https://github.com/sachaos/viddy/releases/download/${VIDDY_VERSION}/viddy-${VIDDY_VERSION}-linux-arm64.tar.gz" \
            | tar -xz -C /usr/local/bin/ viddy
    else
        curl -fsSL "https://github.com/sachaos/viddy/releases/download/${VIDDY_VERSION}/viddy-${VIDDY_VERSION}-linux-x86_64.tar.gz" \
            | tar -xz -C /usr/local/bin/ viddy
    fi
fi

# Install ttyd (not in apt)
if [ "${INSTALLTTYD}" = "true" ]; then
    echo "Installing ttyd..."
    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL -o /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.aarch64
    else
        curl -fsSL -o /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
    fi
    chmod +x /usr/local/bin/ttyd
fi

echo "Terminal Extras installed successfully!"
