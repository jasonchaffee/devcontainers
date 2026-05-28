#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "npm installed" command -v npm
check "codex installed" command -v codex

reportResults
