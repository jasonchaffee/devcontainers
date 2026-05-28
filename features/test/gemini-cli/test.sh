#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "gemini installed" command -v gemini

reportResults
