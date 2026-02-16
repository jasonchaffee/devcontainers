#!/bin/bash
set -e

echo "Testing Google Cloud CLI..."

# Check gcloud installation
echo "Checking gcloud..."
if command -v gcloud &> /dev/null; then
    echo "[OK] gcloud installed: $(gcloud --version 2>/dev/null | head -1)"
else
    echo "[FAIL] gcloud not found"
    exit 1
fi

# Check gsutil
echo ""
echo "Checking gsutil..."
if command -v gsutil &> /dev/null; then
    echo "[OK] gsutil installed"
else
    echo "[FAIL] gsutil not found"
    exit 1
fi

# Check bq
echo ""
echo "Checking bq..."
if command -v bq &> /dev/null; then
    echo "[OK] bq installed"
else
    echo "[FAIL] bq not found"
    exit 1
fi

# Check additional components
echo ""
echo "Checking installed components..."
gcloud components list --filter="state.name=Installed" 2>/dev/null | head -20 || echo "Component list unavailable"

echo ""
echo "Google Cloud CLI test passed!"
