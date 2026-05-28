#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "libxrender available" bash -c "ldconfig -p 2>/dev/null | grep -q libXrender || test -f /usr/lib/x86_64-linux-gnu/libXrender.so.1"
check "libxtst available" bash -c "ldconfig -p 2>/dev/null | grep -q libXtst || test -f /usr/lib/x86_64-linux-gnu/libXtst.so.6"
check "libxi available" bash -c "ldconfig -p 2>/dev/null | grep -q libXi || test -f /usr/lib/x86_64-linux-gnu/libXi.so.6"

reportResults
