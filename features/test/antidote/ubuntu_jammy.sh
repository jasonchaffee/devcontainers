#!/bin/bash
set -e

echo "Testing Antidote on Ubuntu Jammy..."

# Check if zsh is installed
echo "Checking Zsh..."
if command -v zsh &> /dev/null; then
    echo "[OK] Zsh installed: $(zsh --version)"
else
    echo "[FAIL] Zsh not found"
    exit 1
fi

# Check Antidote is installed
echo ""
echo "Checking Antidote..."
ANTIDOTE_DIR="${HOME}/.antidote"
if [ -d "$ANTIDOTE_DIR" ]; then
    echo "[OK] Antidote installed at $ANTIDOTE_DIR"
else
    echo "[FAIL] Antidote not found at $ANTIDOTE_DIR"
    exit 1
fi

echo ""
echo "Antidote Ubuntu Jammy scenario passed!"
