#!/bin/bash
set -e

echo "Installing Terminal Extras..."

# Dependencies (curl, ca-certificates) provided by common-utils via dependsOn

# Detect architecture (cross-platform)
MACHINE_ARCH=$(uname -m)
case "${MACHINE_ARCH}" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${MACHINE_ARCH}"; exit 1 ;;
esac

# Install package manager tools
if command -v apt-get &> /dev/null; then
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
elif command -v apk &> /dev/null; then
    if [ "${INSTALLTMUX}" = "true" ]; then
        echo "Installing tmux..."
        apk add --no-cache tmux
    fi

    if [ "${INSTALLBTOP}" = "true" ]; then
        echo "Installing btop..."
        apk add --no-cache btop
    fi
elif command -v dnf &> /dev/null; then
    if [ "${INSTALLTMUX}" = "true" ]; then
        echo "Installing tmux..."
        dnf install -y tmux
    fi

    if [ "${INSTALLBTOP}" = "true" ]; then
        echo "Installing btop..."
        dnf install -y btop
    fi
elif command -v yum &> /dev/null; then
    if [ "${INSTALLTMUX}" = "true" ]; then
        echo "Installing tmux..."
        yum install -y tmux
    fi

    if [ "${INSTALLBTOP}" = "true" ]; then
        echo "Installing btop..."
        yum install -y epel-release
        yum install -y btop
    fi
fi

# Install viddy (binary download, works on all platforms)
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

# Install ttyd (binary download, works on all platforms)
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
