#!/bin/bash
set -e

echo "Testing Terminal Extras on Alpine..."

for tool in tmux btop viddy; do
    if command -v $tool &> /dev/null; then
        echo "[OK] $tool installed"
    else
        echo "[FAIL] $tool not found"
        exit 1
    fi
done

echo ""
echo "Terminal Extras Alpine scenario passed!"
