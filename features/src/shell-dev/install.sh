#!/bin/bash
set -e

echo "Installing Shell Development Tools..."

if command -v apt-get &> /dev/null; then
    echo "Updating apt-get..."
    apt-get update || (sleep 5 && apt-get update) || (sleep 10 && apt-get update)

    if [ "${INSTALLSHELLCHECK}" = "true" ]; then
        echo "Installing shellcheck..."
        apt-get install -y --no-install-recommends shellcheck
    fi

    if [ "${INSTALLTLDR}" = "true" ]; then
        echo "Installing tldr..."
        apt-get install -y --no-install-recommends tldr
    fi

    rm -rf /var/lib/apt/lists/*
elif command -v apk &> /dev/null; then
    if [ "${INSTALLSHELLCHECK}" = "true" ]; then
        echo "Installing shellcheck..."
        apk add --no-cache shellcheck
    fi

    if [ "${INSTALLTLDR}" = "true" ]; then
        echo "Installing tldr..."
        apk add --no-cache tldr
    fi
elif command -v dnf &> /dev/null; then
    if [ "${INSTALLSHELLCHECK}" = "true" ]; then
        echo "Installing shellcheck..."
        dnf install -y --allowerasing ShellCheck
    fi

    if [ "${INSTALLTLDR}" = "true" ]; then
        echo "Installing tldr..."
        dnf install -y --allowerasing tldr
    fi
elif command -v yum &> /dev/null; then
    if [ "${INSTALLSHELLCHECK}" = "true" ]; then
        echo "Installing shellcheck..."
        yum install -y --allowerasing epel-release
        yum install -y --allowerasing ShellCheck
    fi

    if [ "${INSTALLTLDR}" = "true" ]; then
        echo "Installing tldr..."
        # tldr not available in yum, install via npm if node available
        if command -v npm &> /dev/null; then
            npm install -g tldr
        else
            echo "Warning: tldr requires npm on RHEL/CentOS, skipping..."
        fi
    fi
fi

echo "Shell Development Tools installed successfully!"
