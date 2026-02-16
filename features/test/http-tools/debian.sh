#!/bin/bash
set -e

echo "Testing HTTP Tools on Debian..."

echo "Checking xh..."
if command -v xh &> /dev/null; then
    echo "[OK] xh installed: $(xh --version 2>&1 | head -1)"
else
    echo "[FAIL] xh not found"
    exit 1
fi

echo ""
echo "HTTP Tools Debian scenario passed!"
