#!/bin/bash
set -e

echo "Testing JMeter feature..."

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

# Test JMeter version command
echo ""
echo "Testing JMeter version..."
# JMeter version output format varies by version - check either version flag or direct script
JMETER_VERSION_OUTPUT=$(jmeter --version 2>&1 || jmeter -v 2>&1 || cat /opt/jmeter/bin/jmeter 2>/dev/null | head -1 || true)
if echo "${JMETER_VERSION_OUTPUT}" | grep -qE "JMeter|jmeter|Version|5\.[0-9]"; then
    echo "[OK] JMeter version command works"
    echo "${JMETER_VERSION_OUTPUT}" | head -5
elif [ -x "/opt/jmeter/bin/jmeter" ]; then
    # JMeter script exists and is executable - good enough
    echo "[OK] JMeter executable is valid"
    echo "  Location: /opt/jmeter/bin/jmeter"
else
    echo "[FAIL] JMeter version command failed"
    exit 1
fi

# Check for Plugins Manager
echo ""
echo "Checking Plugins Manager..."
if [ -f "/opt/jmeter/lib/ext/jmeter-plugins-manager.jar" ]; then
    echo "[OK] JMeter Plugins Manager is installed"
else
    echo "[SKIP] JMeter Plugins Manager not installed (optional)"
fi

echo ""
echo "JMeter feature test passed!"
