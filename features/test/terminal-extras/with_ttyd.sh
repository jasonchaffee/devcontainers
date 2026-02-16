#!/bin/bash
set -e

echo "Testing Terminal Extras with installTtyd=true..."

# Check tmux
echo "Checking tmux..."
if command -v tmux &> /dev/null; then
    echo "[OK] tmux installed"
else
    echo "[FAIL] tmux not found"
    exit 1
fi

# Check btop
echo ""
echo "Checking btop..."
if command -v btop &> /dev/null; then
    echo "[OK] btop installed"
else
    echo "[FAIL] btop not found"
    exit 1
fi

# Check viddy
echo ""
echo "Checking viddy..."
if command -v viddy &> /dev/null; then
    echo "[OK] viddy installed"
else
    echo "[FAIL] viddy not found"
    exit 1
fi

# ttyd should be installed
echo ""
echo "Checking ttyd..."
if command -v ttyd &> /dev/null; then
    echo "[OK] ttyd installed"
else
    echo "[FAIL] ttyd not found (should be installed with installTtyd=true)"
    exit 1
fi

echo ""
echo "Terminal Extras with_ttyd scenario passed!"
