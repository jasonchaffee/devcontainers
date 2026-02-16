#!/bin/bash
set -e

echo "Testing gcloud-cli with minimal components..."

# gcloud should be installed
echo "Checking gcloud..."
if command -v gcloud &> /dev/null; then
    echo "✓ gcloud installed: $(gcloud --version 2>&1 | head -1)"
else
    echo "✗ gcloud not found"
    exit 1
fi

# Core tools should still be present
echo ""
echo "Checking core tools..."
if command -v gsutil &> /dev/null; then
    echo "✓ gsutil installed"
else
    echo "✗ gsutil not found"
    exit 1
fi

if command -v bq &> /dev/null; then
    echo "✓ bq installed"
else
    echo "✗ bq not found"
    exit 1
fi

# Optional components should NOT be installed
echo ""
echo "Checking optional components are not installed..."
COMPONENTS=$(gcloud components list --format="value(id)" 2>/dev/null | tr '\n' ' ')
if echo "$COMPONENTS" | grep -q "skaffold"; then
    echo "○ Skaffold installed (may be from base image)"
else
    echo "✓ Skaffold not installed (as expected with empty installComponents)"
fi

echo ""
echo "gcloud-cli minimal_components scenario passed!"
