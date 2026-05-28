#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "shellcheck installed" command -v shellcheck
check "tldr installed" command -v tldr

reportResults
