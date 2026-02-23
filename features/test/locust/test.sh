#!/bin/bash
set -e

echo "Testing Locust feature..."

# Check if Python is available (Locust dependency)
echo "Checking Python dependency..."
if command -v python3 &> /dev/null; then
    echo "[OK] Python is available: $(python3 --version 2>&1)"
else
    echo "[FAIL] Python not found (Locust requires Python)"
    exit 1
fi

# Check if Locust is available
echo ""
echo "Checking Locust installation..."
if command -v locust &> /dev/null; then
    echo "[OK] Locust is available"
else
    echo "[FAIL] Locust not found in PATH"
    exit 1
fi

# Test Locust version command
echo ""
echo "Testing Locust version..."
LOCUST_VERSION_OUTPUT=$(locust --version 2>&1 || true)
if echo "${LOCUST_VERSION_OUTPUT}" | grep -qiE "locust|[0-9]+\.[0-9]+"; then
    echo "[OK] Locust version command works"
    echo "  ${LOCUST_VERSION_OUTPUT}"
else
    echo "[FAIL] Locust version command failed"
    exit 1
fi

echo ""
echo "Locust feature test passed!"
