#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "bun installed" command -v bun
check "bun in /usr/local/bin" test -x /usr/local/bin/bun
check "bun version runs" bun --version

reportResults
