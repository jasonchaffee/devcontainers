#!/bin/bash
set -e

echo "Installing Modern CLI Tools..."

# Dependencies (curl, ca-certificates) provided by common-utils via dependsOn

# Install apt-based tools
apt-get update

if [ "${INSTALLBAT}" = "true" ]; then
    echo "Installing bat..."
    apt-get install -y --no-install-recommends bat
fi

if [ "${INSTALLFD}" = "true" ]; then
    echo "Installing fd..."
    apt-get install -y --no-install-recommends fd-find
    ln -sf $(which fdfind) /usr/local/bin/fd
fi

if [ "${INSTALLRIPGREP}" = "true" ]; then
    echo "Installing ripgrep..."
    apt-get install -y --no-install-recommends ripgrep
fi

if [ "${INSTALLZOXIDE}" = "true" ]; then
    echo "Installing zoxide..."
    apt-get install -y --no-install-recommends zoxide
fi

if [ "${INSTALLDELTA}" = "true" ]; then
    echo "Installing delta..."
    apt-get install -y --no-install-recommends git-delta
fi

if [ "${INSTALLCOLORDIFF}" = "true" ]; then
    echo "Installing colordiff..."
    apt-get install -y --no-install-recommends colordiff
fi

if [ "${INSTALLFZF}" = "true" ]; then
    echo "Installing fzf..."
    apt-get install -y --no-install-recommends fzf
fi

rm -rf /var/lib/apt/lists/*

# Install eza (not in apt, download from GitHub)
if [ "${INSTALLEZA}" = "true" ]; then
    echo "Installing eza..."
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz \
            | tar -xz -C /usr/local/bin/
    else
        curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz \
            | tar -xz -C /usr/local/bin/
    fi
fi

# Install yq (not in apt, download from GitHub)
if [ "${INSTALLYQ}" = "true" ]; then
    echo "Installing yq..."
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64
    else
        curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    fi
    chmod +x /usr/local/bin/yq
fi

echo "Modern CLI Tools installed successfully!"
