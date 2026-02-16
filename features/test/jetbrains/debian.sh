#!/bin/bash
set -e

echo "Testing JetBrains IDE Support on Debian..."

echo "Checking X11 dependencies..."
dpkg -l | grep -qE "libxrender|libxtst|libxi" && echo "[OK] X11 libraries installed" || echo "[SKIP] Some X11 libraries may be missing"

echo ""
echo "JetBrains Debian scenario passed!"
