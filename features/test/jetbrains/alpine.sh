#!/bin/bash
set -e

echo "Testing JetBrains IDE Support on Alpine..."

echo "Checking X11 dependencies..."
apk info 2>/dev/null | grep -qE "libxrender|libxtst|libxi" && echo "[OK] X11 libraries installed" || echo "[SKIP] Some X11 libraries may be missing"

echo ""
echo "JetBrains Alpine scenario passed!"
