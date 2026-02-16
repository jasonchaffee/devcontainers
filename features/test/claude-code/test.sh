#!/bin/bash
set -e

echo "Testing Claude Code CLI..."

# Check if claude is installed
echo "Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    echo "✓ Claude Code CLI installed"
    claude --version 2>&1 | head -1 || true
else
    echo "✗ Claude Code CLI not found"
    exit 1
fi

# Check status line scripts directory
echo ""
echo "Checking status line installation..."
SCRIPTS_DIR="${HOME}/.claude/scripts"
if [ -d "$SCRIPTS_DIR" ]; then
    echo "✓ Scripts directory exists at $SCRIPTS_DIR"
    ls -la "$SCRIPTS_DIR" 2>/dev/null | head -5 || true
else
    echo "○ Scripts directory not found (status line may not be installed)"
fi

echo ""
echo "Claude Code CLI test passed!"
