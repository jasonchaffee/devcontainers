#!/bin/bash
set -e

echo "Testing JMeter feature..."

# Check if Java is available (JMeter dependency)
echo "Checking Java dependency..."
if command -v java &> /dev/null; then
    echo "✓ Java is available: $(java --version 2>&1 | head -1)"
else
    echo "✗ Java not found (JMeter requires Java)"
    exit 1
fi

# Check if JMeter is available
echo ""
echo "Checking JMeter installation..."
if command -v jmeter &> /dev/null; then
    echo "✓ JMeter is available"
else
    echo "✗ JMeter not found in PATH"
    exit 1
fi

# Check JMETER_HOME
echo ""
echo "Checking JMETER_HOME..."
if [ -d "/opt/jmeter" ]; then
    echo "✓ JMETER_HOME exists at /opt/jmeter"
else
    echo "✗ JMETER_HOME not found"
    exit 1
fi

# Test JMeter version command
echo ""
echo "Testing JMeter version..."
if jmeter --version 2>&1 | grep -q "Apache JMeter"; then
    echo "✓ JMeter version command works"
    jmeter --version 2>&1 | head -5
else
    echo "✗ JMeter version command failed"
    exit 1
fi

# Check for Plugins Manager
echo ""
echo "Checking Plugins Manager..."
if [ -f "/opt/jmeter/lib/ext/jmeter-plugins-manager.jar" ]; then
    echo "✓ JMeter Plugins Manager is installed"
else
    echo "○ JMeter Plugins Manager not installed (optional)"
fi

echo ""
echo "JMeter feature test passed!"
