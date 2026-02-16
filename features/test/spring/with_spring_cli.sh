#!/bin/bash
set -e

echo "Testing Spring with installSpringCli=true..."

# Check if Java is available
echo "Checking Java dependency..."
if command -v java &> /dev/null; then
    echo "[OK] Java is available: $(java --version 2>&1 | head -1)"
else
    echo "[FAIL] Java not found"
    exit 1
fi

# Check if Spring CLI is installed
echo ""
echo "Checking Spring CLI..."
if command -v spring &> /dev/null; then
    echo "[OK] Spring CLI is installed"
    spring --version 2>&1 | head -3 || true
else
    echo "[FAIL] Spring CLI not found (should be installed with installSpringCli=true)"
    exit 1
fi

echo ""
echo "Spring with_spring_cli scenario passed!"
