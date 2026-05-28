#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "tmux installed" command -v tmux
check "btop installed" command -v btop
check "viddy installed" command -v viddy
check "tldr installed" command -v tldr
check "ttyd not installed by default" bash -c "! command -v ttyd"

reportResults
