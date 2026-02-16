#!/bin/bash
set -e

echo "Testing Modern CLI Tools on Alpine..."

# Check key tools
for tool in bat eza rg fzf yq; do
    if command -v $tool &> /dev/null; then
        echo "[OK] $tool installed"
    else
        echo "[FAIL] $tool not found"
        exit 1
    fi
done

echo ""
echo "Modern CLI Tools Alpine scenario passed!"
