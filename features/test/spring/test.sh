#!/bin/bash
set -e

echo "Testing Spring Boot feature..."

# Check if Java is available (Spring depends on Java)
echo "Checking Java dependency..."
if command -v java &> /dev/null; then
    echo "✓ Java is available: $(java --version 2>&1 | head -1)"
else
    echo "✗ Java not found (Spring feature depends on Java)"
    exit 1
fi

# Check Spring CLI if it was installed
echo ""
echo "Checking Spring CLI (optional)..."
if command -v spring &> /dev/null; then
    echo "✓ Spring CLI is available"
else
    echo "○ Spring CLI not installed (optional - set installSpringCli: true to enable)"
fi

echo ""
echo "Spring Boot feature test passed!"
echo ""
echo "Note: IDE extensions (Spring Boot Tools, Spring Initializr, etc.)"
echo "will be installed when the IDE loads the devcontainer."
