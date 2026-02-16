#!/bin/bash
set -e

echo "Testing Claude Code with specific version..."

# Claude should be installed
echo "Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    VERSION_OUTPUT=$(claude --version 2>&1 || true)
    echo "[OK] Claude Code CLI installed: ${VERSION_OUTPUT}"
else
    echo "[FAIL] Claude Code CLI not found"
    exit 1
fi

echo ""
echo "Claude Code specific_version scenario passed!"
