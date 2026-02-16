#!/bin/bash
set -e

echo "Testing OpenAI Codex CLI..."

# Check npm is available
echo "Checking npm..."
if command -v npm &> /dev/null; then
    echo "[OK] npm installed: $(npm --version)"
else
    echo "[FAIL] npm not found"
    exit 1
fi

# Check Codex CLI installation
echo ""
echo "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    echo "[OK] Codex CLI installed"
    codex --version 2>/dev/null || echo "  (version info not available)"
else
    echo "[FAIL] Codex CLI not found"
    exit 1
fi

echo ""
echo "Codex CLI test passed!"
