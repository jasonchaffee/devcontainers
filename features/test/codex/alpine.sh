#!/bin/bash
set -e

echo "Testing Codex CLI on Alpine..."

# Check if npm is available
echo "Checking npm..."
if command -v npm &> /dev/null; then
    echo "✓ npm installed: $(npm --version)"
else
    echo "✗ npm not found"
    exit 1
fi

# Check if Codex CLI is installed
echo ""
echo "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    echo "✓ Codex CLI installed"
    codex --version 2>&1 | head -1 || true
else
    echo "✗ Codex CLI not found"
    exit 1
fi

echo ""
echo "Codex CLI Alpine scenario passed!"
