#!/bin/bash
set -e

echo "Testing Shell Development Tools..."

# Check shellcheck
echo "Checking shellcheck..."
if command -v shellcheck &> /dev/null; then
    echo "✓ shellcheck installed: $(shellcheck --version 2>&1 | head -2 | tail -1)"
else
    echo "✗ shellcheck not found"
    exit 1
fi

# Check tldr
echo ""
echo "Checking tldr..."
if command -v tldr &> /dev/null; then
    echo "✓ tldr installed"
else
    echo "✗ tldr not found"
    exit 1
fi

echo ""
echo "Shell Development Tools test passed!"
