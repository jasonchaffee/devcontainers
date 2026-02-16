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

echo "JetBrains IDE dependencies installed successfully!"
