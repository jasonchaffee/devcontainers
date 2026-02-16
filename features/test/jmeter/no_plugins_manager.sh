#!/bin/bash
set -e

echo "Testing JMeter with installPluginsManager=false..."

# Check if Java is available (JMeter dependency)
echo "Checking Java dependency..."
if command -v java &> /dev/null; then
    echo "[OK] Java is available: $(java --version 2>&1 | head -1)"
else
    echo "[FAIL] Java not found (JMeter requires Java)"
    exit 1
fi

# Check if JMeter is available
echo ""
echo "Checking JMeter installation..."
if command -v jmeter &> /dev/null; then
    echo "[OK] JMeter is available"
else
    echo "[FAIL] JMeter not found in PATH"
    exit 1
fi

# Check JMETER_HOME
echo ""
echo "Checking JMETER_HOME..."
if [ -d "/opt/jmeter" ]; then
    echo "[OK] JMETER_HOME exists at /opt/jmeter"
else
    echo "[FAIL] JMETER_HOME not found"
    exit 1
fi

# Plugins Manager should NOT be installed
echo ""
echo "Checking Plugins Manager is NOT installed..."
if [ -f "/opt/jmeter/lib/ext/jmeter-plugins-manager.jar" ]; then
    echo "[FAIL] Plugins Manager should not be installed when installPluginsManager=false"
    exit 1
else
    echo "[OK] Plugins Manager correctly not installed"
fi

echo ""
echo "JMeter no_plugins_manager scenario passed!"
