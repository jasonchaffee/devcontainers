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
    echo "Updating apt-get..."
    apt-get update || (sleep 5 && apt-get update) || (sleep 10 && apt-get update)

    if [ "${INSTALLTMUX}" = "true" ]; then
        echo "Installing tmux..."
        apt-get install -y --no-install-recommends tmux
    fi

    if [ "${INSTALLBTOP}" = "true" ]; then
        echo "Installing btop..."
        if apt-cache show btop &> /dev/null; then
            apt-get install -y --no-install-recommends btop
        else
            echo "btop not found in repository, downloading binary..."
            if [ "$ARCH" = "arm64" ]; then
                BTOP_ARCH="aarch64"
            else
                BTOP_ARCH="x86_64"
            fi
            curl -fsSL "https://github.com/aristocratos/btop/releases/latest/download/btop-${BTOP_ARCH}-unknown-linux-musl.tbz" | tar -xj -C /tmp
            mkdir -p /usr/local/bin /usr/local/share/btop
            cp /tmp/btop/bin/btop /usr/local/bin/
            cp -r /tmp/btop/themes /usr/local/share/btop/
            rm -rf /tmp/btop
        fi
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
        if dnf list btop &> /dev/null; then
            dnf install -y btop
        else
            echo "btop not found in repository, downloading binary..."
            if [ "$ARCH" = "arm64" ]; then
                BTOP_ARCH="aarch64"
            else
                BTOP_ARCH="x86_64"
            fi
            curl -fsSL "https://github.com/aristocratos/btop/releases/latest/download/btop-${BTOP_ARCH}-unknown-linux-musl.tbz" | tar -xj -C /tmp
            mkdir -p /usr/local/bin /usr/local/share/btop
            cp /tmp/btop/bin/btop /usr/local/bin/
            cp -r /tmp/btop/themes /usr/local/share/btop/
            rm -rf /tmp/btop
        fi
    fi
elif command -v yum &> /dev/null; then
    if [ "${INSTALLTMUX}" = "true" ]; then
        echo "Installing tmux..."
        yum install -y tmux
    fi

    if [ "${INSTALLBTOP}" = "true" ]; then
        echo "Installing btop..."
        if yum list btop &> /dev/null; then
            yum install -y btop
        else
            echo "btop not found in repository, downloading binary..."
            if [ "$ARCH" = "arm64" ]; then
                BTOP_ARCH="aarch64"
            else
                BTOP_ARCH="x86_64"
            fi
            curl -fsSL "https://github.com/aristocratos/btop/releases/latest/download/btop-${BTOP_ARCH}-unknown-linux-musl.tbz" | tar -xj -C /tmp
            mkdir -p /usr/local/bin /usr/local/share/btop
            cp /tmp/btop/bin/btop /usr/local/bin/
            cp -r /tmp/btop/themes /usr/local/share/btop/
            rm -rf /tmp/btop
        fi
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
