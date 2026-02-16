#!/bin/bash
set -e

echo "Testing Modern CLI Tools on Debian..."

# Check key tools
for tool in bat eza rg fzf yq; do
    if command -v $tool &> /dev/null; then
        echo "✓ $tool installed"
    else
        echo "✗ $tool not found"
        exit 1
    fi
done

echo ""
echo "Modern CLI Tools Debian scenario passed!"
