#!/bin/bash
set -e

echo "Testing Modern CLI Tools..."

FAILED=0

# Check bat
echo "Checking bat..."
if command -v bat &> /dev/null; then
    echo "[OK] bat installed: $(bat --version 2>&1 | head -1)"
else
    echo "[FAIL] bat not found"
    FAILED=1
fi

# Check eza
echo ""
echo "Checking eza..."
if command -v eza &> /dev/null; then
    echo "[OK] eza installed: $(eza --version 2>&1 | head -1)"
else
    echo "[FAIL] eza not found"
    FAILED=1
fi

# Check fd
echo ""
echo "Checking fd..."
if command -v fd &> /dev/null; then
    echo "[OK] fd installed: $(fd --version 2>&1 | head -1)"
elif command -v fdfind &> /dev/null; then
    echo "[OK] fd installed as fdfind: $(fdfind --version 2>&1 | head -1)"
else
    echo "[FAIL] fd not found"
    FAILED=1
fi

# Check ripgrep
echo ""
echo "Checking ripgrep..."
if command -v rg &> /dev/null; then
    echo "[OK] ripgrep installed: $(rg --version 2>&1 | head -1)"
else
    echo "[FAIL] ripgrep not found"
    FAILED=1
fi

# Check zoxide
echo ""
echo "Checking zoxide..."
if command -v zoxide &> /dev/null; then
    echo "[OK] zoxide installed: $(zoxide --version 2>&1 | head -1)"
else
    echo "[FAIL] zoxide not found"
    FAILED=1
fi

# Check delta
echo ""
echo "Checking delta..."
if command -v delta &> /dev/null; then
    echo "[OK] delta installed: $(delta --version 2>&1 | head -1)"
else
    echo "[FAIL] delta not found"
    FAILED=1
fi

# Check fzf
echo ""
echo "Checking fzf..."
if command -v fzf &> /dev/null; then
    echo "[OK] fzf installed: $(fzf --version 2>&1 | head -1)"
else
    echo "[FAIL] fzf not found"
    FAILED=1
fi

# Check yq
echo ""
echo "Checking yq..."
if command -v yq &> /dev/null; then
    echo "[OK] yq installed: $(yq --version 2>&1 | head -1)"
else
    echo "[FAIL] yq not found"
    FAILED=1
fi

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "Some tools failed to install"
    exit 1
fi

echo ""
echo "Modern CLI Tools test passed!"
