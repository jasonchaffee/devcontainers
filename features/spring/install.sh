#!/bin/bash
set -e

INSTALLSPRINGCLI="${INSTALLSPRINGCLI:-false}"

echo "Installing Spring Boot development tools..."

# Spring CLI installation (optional)
if [ "${INSTALLSPRINGCLI}" = "true" ]; then
    echo "Installing Spring CLI..."

    # Determine target user
    if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
        TARGET_USER="${_REMOTE_USER}"
        TARGET_HOME=$(eval echo ~${_REMOTE_USER})
    else
        TARGET_USER="${USER:-root}"
        TARGET_HOME="${HOME:-/root}"
    fi

    # Spring CLI requires SDKMAN or manual install
    # Using manual install via downloading from GitHub releases
    SPRING_CLI_VERSION="0.9.0"
    INSTALL_DIR="/usr/local/spring-cli"

    # Check architecture
    ARCH=$(uname -m)
    case "${ARCH}" in
        x86_64|amd64)
            ARCH_SUFFIX="x86_64"
            ;;
        aarch64|arm64)
            ARCH_SUFFIX="aarch64"
            ;;
        *)
            echo "Warning: Unsupported architecture ${ARCH} for Spring CLI"
            exit 0
            ;;
    esac

    # Download and install
    DOWNLOAD_URL="https://github.com/spring-projects/spring-cli/releases/download/v${SPRING_CLI_VERSION}/spring-cli-${SPRING_CLI_VERSION}-linux-${ARCH_SUFFIX}.tar.gz"

    mkdir -p "${INSTALL_DIR}"
    curl -fsSL "${DOWNLOAD_URL}" | tar -xz -C "${INSTALL_DIR}" 2>/dev/null || {
        echo "Warning: Failed to download Spring CLI. It can be installed manually later."
        echo "Visit: https://docs.spring.io/spring-cli/reference/installation.html"
        exit 0
    }

    # Create symlink
    ln -sf "${INSTALL_DIR}/spring" /usr/local/bin/spring 2>/dev/null || true

    # Verify installation
    if command -v spring &> /dev/null; then
        echo "Spring CLI installed successfully: $(spring --version 2>/dev/null || echo 'version unknown')"
    else
        echo "Warning: Spring CLI installation could not be verified"
    fi
else
    echo "Skipping Spring CLI installation (set installSpringCli: true to enable)"
fi

echo "Spring Boot development tools configured successfully"
echo ""
echo "IDE extensions will be installed automatically:"
echo "  VS Code: Spring Boot Tools, Spring Initializr, Spring Boot Dashboard"
echo "  IntelliJ: Spring, Spring Boot"
