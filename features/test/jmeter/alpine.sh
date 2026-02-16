#!/bin/bash
set -e

echo "Testing JMeter on Alpine..."

# Check if Java is available
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

echo ""
echo "JMeter Alpine scenario passed!"
