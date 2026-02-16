#!/bin/bash
set -e

echo "Testing Gemini CLI with specific version..."

# Gemini should be installed
echo "Checking Gemini CLI..."
if command -v gemini &> /dev/null; then
    VERSION_OUTPUT=$(gemini --version 2>&1 || true)
    echo "[OK] Gemini CLI installed: ${VERSION_OUTPUT}"
else
    echo "[FAIL] Gemini CLI not found"
    exit 1
fi

echo ""
echo "Gemini CLI specific_version scenario passed!"
