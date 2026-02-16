#!/bin/bash
set -e

echo "Installing JetBrains IDE dependencies..."

# Required dependencies for JetBrains IDEs (IntelliJ, PyCharm, WebStorm, GoLand, etc.)
# See: https://www.jetbrains.com/help/idea/prerequisites-for-dev-containers.html
#
# Required packages:
# - curl: For downloading IDE components
# - unzip: For extracting IDE components
# - procps: Process utilities (provides ps command)
# - libxext, libxrender, libxtst, libxi: X11 libraries for GUI rendering
# - libfreetype6: Font rendering library

if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
        procps \
        libxext6 \
        libxrender1 \
        libxtst6 \
        libxi6 \
        libfreetype6
    rm -rf /var/lib/apt/lists/*
elif command -v apk &> /dev/null; then
    apk add --no-cache \
        curl \
        unzip \
        procps \
        libxext \
        libxrender \
        libxtst \
        libxi \
        freetype
elif command -v dnf &> /dev/null; then
    dnf install -y \
        curl \
        unzip \
        procps-ng \
        libXext \
        libXrender \
        libXtst \
        libXi \
        freetype
elif command -v yum &> /dev/null; then
    yum install -y \
        curl \
        unzip \
        procps \
        libXext \
        libXrender \
        libXtst \
        libXi \
        freetype
fi

echo "JetBrains IDE dependencies installed successfully!"
