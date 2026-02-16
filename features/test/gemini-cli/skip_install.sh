#!/bin/bash
set -e

echo "Testing Gemini CLI with install=false..."

# Gemini should NOT be installed
echo "Verifying Gemini CLI is NOT installed..."
if command -v gemini &> /dev/null; then
    echo "[FAIL] Gemini CLI should not be installed when install=false"
    exit 1
else
    echo "[OK] Gemini CLI correctly not installed"
fi

echo ""
echo "Gemini CLI skip_install scenario passed!"
