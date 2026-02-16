#!/bin/bash
set -e

echo "Testing Terminal Extras..."

# Check tmux
echo "Checking tmux..."
if command -v tmux &> /dev/null; then
    echo "✓ tmux installed: $(tmux -V 2>&1)"
else
    echo "✗ tmux not found"
    exit 1
fi

# Check btop
echo ""
echo "Checking btop..."
if command -v btop &> /dev/null; then
    echo "✓ btop installed: $(btop --version 2>&1 | head -1)"
else
    echo "✗ btop not found"
    exit 1
fi

# Check viddy
echo ""
echo "Checking viddy..."
if command -v viddy &> /dev/null; then
    echo "✓ viddy installed: $(viddy --version 2>&1 | head -1)"
else
    echo "✗ viddy not found"
    exit 1
fi

# ttyd is optional (default false)
echo ""
echo "Checking ttyd (optional)..."
if command -v ttyd &> /dev/null; then
    echo "✓ ttyd installed"
else
    echo "○ ttyd not installed (optional - set installTtyd: true to enable)"
fi

echo ""
echo "Terminal Extras test passed!"
