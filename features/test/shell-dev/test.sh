#!/bin/bash
set -e

echo "Testing Shell Development Tools..."

# Check shellcheck
echo "Checking shellcheck..."
if command -v shellcheck &> /dev/null; then
    echo "[OK] shellcheck installed: $(shellcheck --version 2>&1 | head -2 | tail -1)"
else
    echo "[FAIL] shellcheck not found"
    exit 1
fi

# Check tldr
echo ""
echo "Checking tldr..."
if command -v tldr &> /dev/null; then
    echo "[OK] tldr installed"
else
    echo "[FAIL] tldr not found"
    exit 1
fi

echo ""
echo "Shell Development Tools test passed!"
