#!/bin/bash
set -e

echo "Testing Spring on Alpine..."

# Check if Java is available
echo "Checking Java dependency..."
if command -v java &> /dev/null; then
    echo "✓ Java is available: $(java --version 2>&1 | head -1)"
else
    echo "✗ Java not found"
    exit 1
fi

# Spring CLI is optional by default
echo ""
echo "Checking Spring CLI (optional)..."
if command -v spring &> /dev/null; then
    echo "✓ Spring CLI installed"
else
    echo "○ Spring CLI not installed (optional - set installSpringCli: true to enable)"
fi

echo ""
echo "Spring Alpine scenario passed!"
