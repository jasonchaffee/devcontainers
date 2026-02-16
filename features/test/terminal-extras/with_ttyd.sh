#!/bin/bash
set -e

echo "Testing Terminal Extras with installTtyd=true..."

# Check tmux
echo "Checking tmux..."
if command -v tmux &> /dev/null; then
    echo "✓ tmux installed"
else
    echo "✗ tmux not found"
    exit 1
fi

# Check btop
echo ""
echo "Checking btop..."
if command -v btop &> /dev/null; then
    echo "✓ btop installed"
else
    echo "✗ btop not found"
    exit 1
fi

# Check viddy
echo ""
echo "Checking viddy..."
if command -v viddy &> /dev/null; then
    echo "✓ viddy installed"
else
    echo "✗ viddy not found"
    exit 1
fi

# ttyd should be installed
echo ""
echo "Checking ttyd..."
if command -v ttyd &> /dev/null; then
    echo "✓ ttyd installed"
else
    echo "✗ ttyd not found (should be installed with installTtyd=true)"
    exit 1
fi

echo ""
echo "Terminal Extras with_ttyd scenario passed!"
