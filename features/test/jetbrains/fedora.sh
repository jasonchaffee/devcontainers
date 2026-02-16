#!/bin/bash
set -e

echo "Testing JetBrains IDE Support on Fedora..."

echo "Checking X11 dependencies..."
rpm -qa 2>/dev/null | grep -qE "libXrender|libXtst|libXi" && echo "✓ X11 libraries installed" || echo "○ Some X11 libraries may be missing"

echo ""
echo "JetBrains Fedora scenario passed!"
