#!/bin/bash
set -e

echo "Testing JMeter on Fedora..."

# Check if Java is available
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

echo ""
echo "JMeter Fedora scenario passed!"
