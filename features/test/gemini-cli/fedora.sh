#!/bin/bash
set -e

echo "Testing Gemini CLI on Fedora..."

# Check if npm is available
echo "Checking npm..."
if command -v npm &> /dev/null; then
    echo "[OK] npm installed: $(npm --version)"
else
    echo "[FAIL] npm not found"
    exit 1
fi

# Check if Gemini CLI is installed
echo ""
echo "Checking Gemini CLI..."
if command -v gemini &> /dev/null; then
    echo "[OK] Gemini CLI installed"
    gemini --version 2>&1 | head -1 || true
else
    echo "[FAIL] Gemini CLI not found"
    exit 1
fi

echo ""
echo "Gemini CLI Fedora scenario passed!"
