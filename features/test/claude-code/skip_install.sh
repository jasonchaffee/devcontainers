#!/bin/bash
set -e

echo "Testing Claude Code with install=false..."

# Claude should NOT be installed
echo "Verifying Claude Code CLI is NOT installed..."
if command -v claude &> /dev/null; then
    echo "[FAIL] Claude Code CLI should not be installed when install=false"
    exit 1
else
    echo "[OK] Claude Code CLI correctly not installed"
fi

echo ""
echo "Claude Code skip_install scenario passed!"
