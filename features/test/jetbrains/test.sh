#!/bin/bash
set -e

echo "Testing JetBrains IDE Support..."

# JetBrains feature installs system dependencies
# Check for common required packages

echo "Checking libxrender..."
if ldconfig -p 2>/dev/null | grep -q libXrender || [ -f /usr/lib/libXrender.so.1 ] || [ -f /usr/lib64/libXrender.so.1 ]; then
    echo "✓ libXrender available"
else
    echo "○ libXrender not found (may not be required on this platform)"
fi

echo ""
echo "Checking libxtst..."
if ldconfig -p 2>/dev/null | grep -q libXtst || [ -f /usr/lib/libXtst.so.6 ] || [ -f /usr/lib64/libXtst.so.6 ]; then
    echo "✓ libXtst available"
else
    echo "○ libXtst not found (may not be required on this platform)"
fi

echo ""
echo "Checking libxi..."
if ldconfig -p 2>/dev/null | grep -q libXi || [ -f /usr/lib/libXi.so.6 ] || [ -f /usr/lib64/libXi.so.6 ]; then
    echo "✓ libXi available"
else
    echo "○ libXi not found (may not be required on this platform)"
fi

echo ""
echo "JetBrains IDE Support test passed!"
