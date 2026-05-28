#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "python3 installed" command -v python3
check "locust installed" command -v locust
check "locust version runs" locust --version

reportResults
