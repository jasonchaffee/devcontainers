#!/bin/bash
set -e

echo "Installing Shell Development Tools..."

apt-get update

if [ "${INSTALLSHELLCHECK}" = "true" ]; then
    echo "Installing shellcheck..."
    apt-get install -y --no-install-recommends shellcheck
fi

if [ "${INSTALLTLDR}" = "true" ]; then
    echo "Installing tldr..."
    apt-get install -y --no-install-recommends tldr
fi

rm -rf /var/lib/apt/lists/*

echo "Shell Development Tools installed successfully!"
