#!/bin/bash
set -e

echo "Testing Claude Code on Debian..."

# Check if claude is installed
echo "Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    echo "✓ Claude Code CLI installed"
    claude --version 2>&1 | head -1 || true
else
    echo "✗ Claude Code CLI not found"
    exit 1
fi

echo ""
echo "Claude Code Debian scenario passed!"
