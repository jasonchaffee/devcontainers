#!/bin/bash
set -e

echo "Testing Shell Development Tools on Alpine..."

echo "Checking shellcheck..."
if command -v shellcheck &> /dev/null; then
    echo "✓ shellcheck installed"
else
    echo "✗ shellcheck not found"
    exit 1
fi

echo ""
echo "Checking tldr..."
if command -v tldr &> /dev/null; then
    echo "✓ tldr installed"
else
    echo "✗ tldr not found"
    exit 1
fi

echo ""
echo "Shell Development Tools Alpine scenario passed!"
