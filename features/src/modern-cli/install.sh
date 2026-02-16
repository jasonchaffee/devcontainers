#!/bin/bash
set -e

echo "Installing Modern CLI Tools..."

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

    if [ "${INSTALLBAT}" = "true" ]; then
        echo "Installing bat..."
        apt-get install -y --no-install-recommends bat
        # On Debian/Ubuntu, bat is installed as batcat - create symlink
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            ln -sf $(which batcat) /usr/local/bin/bat
        fi
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
elif command -v apk &> /dev/null; then
    if [ "${INSTALLBAT}" = "true" ]; then
        echo "Installing bat..."
        apk add --no-cache bat
    fi

    if [ "${INSTALLFD}" = "true" ]; then
        echo "Installing fd..."
        apk add --no-cache fd
    fi

    if [ "${INSTALLRIPGREP}" = "true" ]; then
        echo "Installing ripgrep..."
        apk add --no-cache ripgrep
    fi

    if [ "${INSTALLZOXIDE}" = "true" ]; then
        echo "Installing zoxide..."
        apk add --no-cache zoxide
    fi

    if [ "${INSTALLDELTA}" = "true" ]; then
        echo "Installing delta..."
        apk add --no-cache delta
    fi

    if [ "${INSTALLCOLORDIFF}" = "true" ]; then
        echo "Installing colordiff..."
        apk add --no-cache colordiff
    fi

    if [ "${INSTALLFZF}" = "true" ]; then
        echo "Installing fzf..."
        apk add --no-cache fzf
    fi
elif command -v dnf &> /dev/null; then
    if [ "${INSTALLBAT}" = "true" ]; then
        echo "Installing bat..."
        dnf install -y bat
    fi

    if [ "${INSTALLFD}" = "true" ]; then
        echo "Installing fd..."
        dnf install -y fd-find
    fi

    if [ "${INSTALLRIPGREP}" = "true" ]; then
        echo "Installing ripgrep..."
        dnf install -y ripgrep
    fi

    if [ "${INSTALLZOXIDE}" = "true" ]; then
        echo "Installing zoxide..."
        dnf install -y zoxide
    fi

    if [ "${INSTALLDELTA}" = "true" ]; then
        echo "Installing delta..."
        dnf install -y git-delta
    fi

    if [ "${INSTALLCOLORDIFF}" = "true" ]; then
        echo "Installing colordiff..."
        dnf install -y colordiff
    fi

    if [ "${INSTALLFZF}" = "true" ]; then
        echo "Installing fzf..."
        dnf install -y fzf
    fi
elif command -v yum &> /dev/null; then
    yum install -y epel-release

    if [ "${INSTALLBAT}" = "true" ]; then
        echo "Installing bat..."
        yum install -y bat
    fi

    if [ "${INSTALLFD}" = "true" ]; then
        echo "Installing fd..."
        yum install -y fd-find
    fi

    if [ "${INSTALLRIPGREP}" = "true" ]; then
        echo "Installing ripgrep..."
        yum install -y ripgrep
    fi

    if [ "${INSTALLZOXIDE}" = "true" ]; then
        echo "Installing zoxide..."
        # zoxide not in EPEL, install via cargo if available
        if command -v cargo &> /dev/null; then
            cargo install zoxide --locked
        else
            echo "Warning: zoxide requires cargo on RHEL/CentOS, skipping..."
        fi
    fi

    if [ "${INSTALLDELTA}" = "true" ]; then
        echo "Installing delta..."
        # delta not in EPEL, download binary
        if [ "$ARCH" = "arm64" ]; then
            echo "Warning: delta binary not available for arm64 on RHEL/CentOS, skipping..."
        else
            DELTA_VERSION=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
            curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar -xz --strip-components=1 -C /usr/local/bin/ "delta-${DELTA_VERSION}-x86_64-unknown-linux-musl/delta"
        fi
    fi

    if [ "${INSTALLCOLORDIFF}" = "true" ]; then
        echo "Installing colordiff..."
        yum install -y colordiff
    fi

    if [ "${INSTALLFZF}" = "true" ]; then
        echo "Installing fzf..."
        yum install -y fzf
    fi
fi

# Install eza (binary download, works on all platforms)
if [ "${INSTALLEZA}" = "true" ]; then
    echo "Installing eza..."
    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz \
            | tar -xz -C /usr/local/bin/
    else
        curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz \
            | tar -xz -C /usr/local/bin/
    fi
fi

# Install yq (binary download, works on all platforms)
if [ "${INSTALLYQ}" = "true" ]; then
    echo "Installing yq..."
    if [ "$ARCH" = "arm64" ]; then
        curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64
    else
        curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    fi
    chmod +x /usr/local/bin/yq
fi

echo "Modern CLI Tools installed successfully!"
