#!/bin/bash
set -e

echo "Testing Google Gemini CLI..."

# Check gemini installation
echo "Checking gemini..."
if command -v gemini &> /dev/null; then
    echo "✓ gemini installed: $(gemini --version 2>/dev/null || echo 'version check requires auth')"
else
    echo "✗ gemini not found"
    exit 1
fi

# Check npm global packages
echo ""
echo "Checking npm global packages..."
npm list -g @google/gemini-cli 2>/dev/null | head -5 || echo "Package info unavailable"

echo ""
echo "Google Gemini CLI test passed!"
