#!/bin/bash
set -e

echo "Testing Antidote on Debian..."

# Check if zsh is installed
echo "Checking Zsh..."
if command -v zsh &> /dev/null; then
    echo "✓ Zsh installed: $(zsh --version)"
else
    echo "✗ Zsh not found"
    exit 1
fi

# Check Antidote is installed
echo ""
echo "Checking Antidote..."
ANTIDOTE_DIR="${HOME}/.antidote"
if [ -d "$ANTIDOTE_DIR" ]; then
    echo "✓ Antidote installed at $ANTIDOTE_DIR"
else
    echo "✗ Antidote not found at $ANTIDOTE_DIR"
    exit 1
fi

echo ""
echo "Antidote Debian scenario passed!"
