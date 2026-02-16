#!/bin/bash
set -e

echo "Testing Shell Development Tools on Debian..."

echo "Checking shellcheck..."
if command -v shellcheck &> /dev/null; then
    echo "[OK] shellcheck installed"
else
    echo "[FAIL] shellcheck not found"
    exit 1
fi

echo ""
echo "Checking tldr..."
if command -v tldr &> /dev/null; then
    echo "[OK] tldr installed"
else
    echo "[FAIL] tldr not found"
    exit 1
fi

echo ""
echo "Shell Development Tools Debian scenario passed!"
