#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "xh installed" command -v xh
check "xh version runs" xh --version

reportResults
