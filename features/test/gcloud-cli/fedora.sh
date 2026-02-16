#!/bin/bash
set -e

echo "Testing gcloud-cli on Fedora..."

# Check if gcloud is installed
echo "Checking gcloud..."
if command -v gcloud &> /dev/null; then
    echo "✓ gcloud installed: $(gcloud --version 2>&1 | head -1)"
else
    echo "✗ gcloud not found"
    exit 1
fi

# Check core tools
echo ""
echo "Checking gsutil..."
if command -v gsutil &> /dev/null; then
    echo "✓ gsutil installed"
else
    echo "✗ gsutil not found"
    exit 1
fi

echo ""
echo "Checking bq..."
if command -v bq &> /dev/null; then
    echo "✓ bq installed"
else
    echo "✗ bq not found"
    exit 1
fi

echo ""
echo "gcloud-cli Fedora scenario passed!"
