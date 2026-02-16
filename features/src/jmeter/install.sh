#!/bin/bash
set -e

VERSION="${VERSION:-5.6.3}"
INSTALLPLUGINSMANAGER="${INSTALLPLUGINSMANAGER:-true}"

echo "Installing Apache JMeter ${VERSION}..."

# Install curl if not present
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y --no-install-recommends curl ca-certificates
    elif command -v apk &> /dev/null; then
        apk add --no-cache curl ca-certificates
    elif command -v dnf &> /dev/null; then
        dnf install -y curl ca-certificates
    elif command -v yum &> /dev/null; then
        yum install -y curl ca-certificates
    fi
fi

# Install directory
JMETER_HOME="/opt/jmeter"
JMETER_BIN="${JMETER_HOME}/bin"

# Download and extract JMeter
DOWNLOAD_URL="https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${VERSION}.tgz"

echo "Downloading from ${DOWNLOAD_URL}..."
mkdir -p "${JMETER_HOME}"

curl -fsSL "${DOWNLOAD_URL}" | tar -xz -C /opt || {
    echo "Error: Failed to download JMeter ${VERSION}"
    echo "Check available versions at: https://archive.apache.org/dist/jmeter/binaries/"
    exit 1
}

# Move to standard location
mv /opt/apache-jmeter-${VERSION}/* "${JMETER_HOME}/"
rmdir /opt/apache-jmeter-${VERSION}

# Create symlinks in /usr/local/bin
ln -sf "${JMETER_BIN}/jmeter" /usr/local/bin/jmeter
ln -sf "${JMETER_BIN}/jmeter-server" /usr/local/bin/jmeter-server

# Install JMeter Plugins Manager (optional but recommended)
if [ "${INSTALLPLUGINSMANAGER}" = "true" ]; then
    echo "Installing JMeter Plugins Manager..."
    PLUGINS_MANAGER_VERSION="1.10"
    PLUGINS_MANAGER_URL="https://jmeter-plugins.org/get/"

    curl -fsSL "${PLUGINS_MANAGER_URL}" -o "${JMETER_HOME}/lib/ext/jmeter-plugins-manager.jar" || {
        echo "Warning: Failed to download JMeter Plugins Manager"
    }

    # Also install command-line plugins manager
    CMD_RUNNER_URL="https://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.3/cmdrunner-2.3.jar"
    curl -fsSL "${CMD_RUNNER_URL}" -o "${JMETER_HOME}/lib/cmdrunner-2.3.jar" 2>/dev/null || true

    if [ -f "${JMETER_HOME}/lib/cmdrunner-2.3.jar" ]; then
        java -cp "${JMETER_HOME}/lib/ext/jmeter-plugins-manager.jar" org.jmeterplugins.repository.PluginManagerCMDInstaller 2>/dev/null || true
    fi

    echo "Plugins Manager installed"
fi

# Set environment variables for all users
cat >> /etc/profile.d/jmeter.sh << 'EOF'
export JMETER_HOME=/opt/jmeter
export PATH="${JMETER_HOME}/bin:${PATH}"
EOF

# Verify installation
if [ -x "${JMETER_BIN}/jmeter" ]; then
    echo ""
    echo "JMeter installed successfully!"
    echo "  Version: ${VERSION}"
    echo "  Location: ${JMETER_HOME}"
    echo ""
    echo "Usage:"
    echo "  jmeter -n -t test.jmx -l results.jtl    # Run test in non-GUI mode"
    echo "  jmeter -g results.jtl -o report/        # Generate HTML report"
    echo "  jmeter                                   # Launch GUI (requires X11)"
else
    echo "Error: JMeter installation failed"
    exit 1
fi
