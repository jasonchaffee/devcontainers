#!/bin/bash
set -e

echo "Testing Codex with install=false..."

# Codex should NOT be installed
echo "Verifying Codex is NOT installed..."
if command -v codex &> /dev/null; then
    echo "✗ Codex should not be installed when install=false"
    exit 1
else
    echo "✓ Codex correctly not installed"
fi

echo ""
echo "Codex skip_install scenario passed!"
