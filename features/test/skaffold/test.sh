#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "skaffold installed" command -v skaffold
check "skaffold in /usr/local/bin" test -x /usr/local/bin/skaffold
check "skaffold version runs" skaffold version

reportResults
