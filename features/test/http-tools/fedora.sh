#!/bin/bash
set -e

echo "Testing HTTP Tools on Fedora..."

echo "Checking xh..."
if command -v xh &> /dev/null; then
    echo "✓ xh installed: $(xh --version 2>&1 | head -1)"
else
    echo "✗ xh not found"
    exit 1
fi

echo ""
echo "HTTP Tools Fedora scenario passed!"
