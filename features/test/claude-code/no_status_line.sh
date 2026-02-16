#!/bin/bash
set -e

echo "Testing Claude Code with installStatusLine=false..."

# Claude should be installed
echo "Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    echo "✓ Claude Code CLI installed"
else
    echo "✗ Claude Code CLI not found"
    exit 1
fi

# Status line should NOT be installed
echo ""
echo "Verifying status line is NOT installed..."
SCRIPTS_DIR="${HOME}/.claude/scripts"
if [ -f "$SCRIPTS_DIR/jasonchaffee-statusline.py" ]; then
    echo "✗ Status line should not be installed when installStatusLine=false"
    exit 1
else
    echo "✓ Status line correctly not installed"
fi

echo ""
echo "Claude Code no_status_line scenario passed!"
