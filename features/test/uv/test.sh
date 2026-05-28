#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "uv installed" command -v uv
check "uv in /usr/local/bin" test -x /usr/local/bin/uv
check "uv version runs" uv --version

reportResults
