#!/bin/bash
set -e

echo "Testing Terminal Extras..."

# Check tmux
echo "Checking tmux..."
if command -v tmux &> /dev/null; then
    echo "[OK] tmux installed: $(tmux -V 2>&1)"
else
    echo "[FAIL] tmux not found"
    exit 1
fi

# Check btop
echo ""
echo "Checking btop..."
if command -v btop &> /dev/null; then
    echo "[OK] btop installed: $(btop --version 2>&1 | head -1)"
else
    echo "[FAIL] btop not found"
    exit 1
fi

# Check viddy
echo ""
echo "Checking viddy..."
if command -v viddy &> /dev/null; then
    echo "[OK] viddy installed: $(viddy --version 2>&1 | head -1)"
else
    echo "[FAIL] viddy not found"
    exit 1
fi

# ttyd is optional (default false)
echo ""
echo "Checking ttyd (optional)..."
if command -v ttyd &> /dev/null; then
    echo "[OK] ttyd installed"
else
    echo "[SKIP] ttyd not installed (optional - set installTtyd: true to enable)"
fi

echo ""
echo "Terminal Extras test passed!"
