#!/bin/bash
set -e

INSTALL_ZSH="${INSTALLZSH:-true}"
SET_DEFAULT_SHELL="${SETDEFAULTSHELL:-false}"

echo "Installing Zsh with Antidote plugin manager..."

# Ensure git is installed (required for Antidote)
if ! command -v git &> /dev/null; then
    echo "Installing git (required for Antidote)..."
    if command -v apt-get &> /dev/null; then
        echo "Updating apt-get..."
        apt-get update || (sleep 5 && apt-get update) || (sleep 10 && apt-get update)
        apt-get install -y --no-install-recommends git
    elif command -v apk &> /dev/null; then
        apk add --no-cache git
    elif command -v dnf &> /dev/null; then
        dnf install -y git
    elif command -v yum &> /dev/null; then
        yum install -y git
    fi
fi

# Install Zsh if requested and not present
if [ "${INSTALL_ZSH}" = "true" ]; then
    if ! command -v zsh &> /dev/null; then
        echo "Installing Zsh..."
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y --no-install-recommends zsh
            rm -rf /var/lib/apt/lists/*
        elif command -v apk &> /dev/null; then
            apk add --no-cache zsh
        elif command -v dnf &> /dev/null; then
            dnf install -y zsh
        elif command -v yum &> /dev/null; then
            yum install -y zsh
        else
            echo "ERROR: Could not install Zsh - unsupported package manager"
            exit 1
        fi
    else
        echo "Zsh already installed: $(zsh --version)"
    fi
fi

# Determine user home directory
if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    USER_HOME=$(eval echo ~${_REMOTE_USER})
    TARGET_USER="${_REMOTE_USER}"
else
    USER_HOME="${HOME:-/root}"
    TARGET_USER="root"
fi

ANTIDOTE_DIR="${USER_HOME}/.antidote"

# Install Antidote
if [ -d "${ANTIDOTE_DIR}" ]; then
    echo "Antidote already installed at ${ANTIDOTE_DIR}"
else
    echo "Installing Antidote to ${ANTIDOTE_DIR}..."
    # Try normal clone first, fall back to SSL-disabled if corporate proxy interferes
    if ! git clone --depth=1 https://github.com/mattmc3/antidote.git "${ANTIDOTE_DIR}" 2>/dev/null; then
        echo "SSL clone failed, retrying with SSL verification disabled (corporate proxy detected)..."
        GIT_SSL_NO_VERIFY=true git clone --depth=1 https://github.com/mattmc3/antidote.git "${ANTIDOTE_DIR}"
    fi
fi

# Create cache directory for plugins
CACHE_DIR="${USER_HOME}/.cache/antidote"
mkdir -p "${CACHE_DIR}"

# Set ownership
if [ "${TARGET_USER}" != "root" ]; then
    chown -R "${TARGET_USER}:${TARGET_USER}" "${ANTIDOTE_DIR}" "${CACHE_DIR}" 2>/dev/null || true
fi

# Set Zsh as default shell if requested
if [ "${SET_DEFAULT_SHELL}" = "true" ] && [ "${TARGET_USER}" != "root" ]; then
    echo "Setting Zsh as default shell for ${TARGET_USER}..."
    chsh -s "$(which zsh)" "${TARGET_USER}" 2>/dev/null || true
fi

echo ""
echo "Antidote installed successfully!"
echo ""
echo "To use Antidote, add this to your ~/.zshrc:"
echo "  source ~/.antidote/antidote.zsh"
echo "  antidote load"
echo ""
echo "And create ~/.zsh_plugins.txt with your plugins."
