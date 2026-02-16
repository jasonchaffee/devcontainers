#!/bin/bash
set -e

echo "Testing Claude Code CLI..."

# Check if claude is installed
echo "Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    echo "[OK] Claude Code CLI installed"
    claude --version 2>&1 | head -1 || true
else
    echo "[FAIL] Claude Code CLI not found"
    exit 1
fi

# Check status line scripts directory and file
echo ""
echo "Checking status line installation..."
SCRIPTS_DIR="${HOME}/.claude/scripts"
STATUSLINE_FILE="${SCRIPTS_DIR}/jasonchaffee-statusline.py"

if [ -d "$SCRIPTS_DIR" ]; then
    echo "[OK] Scripts directory exists at $SCRIPTS_DIR"
    ls -la "$SCRIPTS_DIR" 2>/dev/null | head -10 || true
else
    echo "[FAIL] Scripts directory not found at $SCRIPTS_DIR"
    exit 1
fi

echo ""
echo "Checking status line script..."
if [ -f "$STATUSLINE_FILE" ]; then
    echo "[OK] Status line script exists at $STATUSLINE_FILE"
else
    echo "[FAIL] Status line script not found at $STATUSLINE_FILE"
    exit 1
fi

echo ""
echo "Claude Code CLI test passed!"
