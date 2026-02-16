#!/bin/bash
set -e

echo "Testing Codex with specific version..."

# Codex should be installed
echo "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    VERSION_OUTPUT=$(codex --version 2>&1 || true)
    echo "[OK] Codex CLI installed: ${VERSION_OUTPUT}"
else
    echo "[FAIL] Codex not found"
    exit 1
fi

echo ""
echo "Codex specific_version scenario passed!"
