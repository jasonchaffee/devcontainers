#!/bin/bash
set -e

echo "Testing Zsh with Antidote..."

# Check Zsh installation
echo "Checking Zsh..."
if command -v zsh &> /dev/null; then
    echo "[OK] Zsh installed: $(zsh --version)"
else
    echo "[FAIL] Zsh not found"
    exit 1
fi

# Check Antidote installation
echo ""
echo "Checking Antidote..."
ANTIDOTE_DIR="${HOME}/.antidote"
if [ -d "${ANTIDOTE_DIR}" ]; then
    echo "[OK] Antidote installed at ${ANTIDOTE_DIR}"
else
    echo "[FAIL] Antidote not found at ${ANTIDOTE_DIR}"
    exit 1
fi

# Check Antidote can be sourced
echo ""
echo "Testing Antidote sourcing..."
if zsh -c "source ${ANTIDOTE_DIR}/antidote.zsh && echo '[OK] Antidote sources successfully'"; then
    :
else
    echo "[FAIL] Failed to source Antidote"
    exit 1
fi

echo ""
echo "Zsh with Antidote test passed!"
