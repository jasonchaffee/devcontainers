#!/bin/bash
set -e

echo "Testing Antidote with setDefaultShell=true..."

# Check if zsh is installed
echo "Checking Zsh..."
if command -v zsh &> /dev/null; then
    echo "✓ Zsh installed: $(zsh --version)"
else
    echo "✗ Zsh not found"
    exit 1
fi

# Check if zsh is the default shell
echo ""
echo "Checking default shell..."
CURRENT_USER="${_REMOTE_USER:-root}"
DEFAULT_SHELL=$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f7 || echo "unknown")

if [[ "$DEFAULT_SHELL" == *"zsh"* ]]; then
    echo "✓ Zsh is default shell: $DEFAULT_SHELL"
else
    echo "✗ Expected zsh as default shell, got: $DEFAULT_SHELL"
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
echo "Antidote setDefaultShell scenario passed!"
