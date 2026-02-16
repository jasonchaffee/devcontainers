#!/bin/bash
set -e

echo "Testing gcloud-cli on Debian..."

# Check if gcloud is installed
echo "Checking gcloud..."
if command -v gcloud &> /dev/null; then
    echo "[OK] gcloud installed: $(gcloud --version 2>&1 | head -1)"
else
    echo "[FAIL] gcloud not found"
    exit 1
fi

# Check core tools
echo ""
echo "Checking gsutil..."
if command -v gsutil &> /dev/null; then
    echo "[OK] gsutil installed"
else
    echo "[FAIL] gsutil not found"
    exit 1
fi

echo ""
echo "Checking bq..."
if command -v bq &> /dev/null; then
    echo "[OK] bq installed"
else
    echo "[FAIL] bq not found"
    exit 1
fi

echo ""
echo "gcloud-cli Debian scenario passed!"
