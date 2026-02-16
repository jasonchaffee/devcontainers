#!/bin/bash
set -e

echo "Testing Dev Container CLI feature..."

# Check if devcontainer CLI is available
echo "Checking devcontainer CLI..."
if command -v devcontainer &> /dev/null; then
    echo "✓ devcontainer CLI is available: $(devcontainer --version)"
else
    echo "✗ devcontainer CLI not found"
    exit 1
fi

# Check if Node.js is available (dependency)
echo ""
echo "Checking Node.js dependency..."
if command -v node &> /dev/null; then
    echo "✓ Node.js is available: $(node --version)"
else
    echo "✗ Node.js not found"
    exit 1
fi

# Test basic command
echo ""
echo "Testing devcontainer help..."
if devcontainer --help > /dev/null 2>&1; then
    echo "✓ devcontainer --help works"
else
    echo "✗ devcontainer --help failed"
    exit 1
fi

echo ""
echo "Dev Container CLI feature test passed!"
