#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Locust..."

# Install pip if not present
if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    echo "Installing pip..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y --no-install-recommends python3-pip
    elif command -v apk &> /dev/null; then
        apk add --no-cache py3-pip
    elif command -v dnf &> /dev/null; then
        dnf install -y python3-pip
    elif command -v yum &> /dev/null; then
        yum install -y python3-pip
    fi
fi

# Determine pip command
PIP_CMD="pip3"
if ! command -v pip3 &> /dev/null; then
    PIP_CMD="pip"
fi

# Install locust
if [ "${VERSION}" = "latest" ]; then
    ${PIP_CMD} install --break-system-packages locust 2>/dev/null \
        || ${PIP_CMD} install locust
else
    ${PIP_CMD} install --break-system-packages "locust==${VERSION}" 2>/dev/null \
        || ${PIP_CMD} install "locust==${VERSION}"
fi

# Verify installation
if command -v locust &> /dev/null; then
    echo ""
    echo "Locust installed successfully!"
    echo "  Version: $(locust --version 2>&1)"
    echo ""
    echo "Usage:"
    echo "  locust -f locustfile.py              # Start with web UI on :8089"
    echo "  locust -f locustfile.py --headless    # Run headless"
else
    echo "Error: Locust installation failed"
    exit 1
fi
