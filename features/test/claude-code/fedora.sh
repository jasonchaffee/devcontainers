#!/bin/bash
set -e

echo "Testing Claude Code on Fedora..."

# Check if claude is installed
echo "Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    echo "[OK] Claude Code CLI installed"
    claude --version 2>&1 | head -1 || true
else
    echo "[FAIL] Claude Code CLI not found"
    exit 1
fi

echo ""
echo "Claude Code Fedora scenario passed!"
