#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "brew installed" command -v brew
check "brew prefix exists" test -d /home/linuxbrew/.linuxbrew
check "brew version runs" brew --version
check "brew library compatibility path exists" test -f /home/linuxbrew/.linuxbrew/Library/Homebrew/brew.sh
check "brew profile exists" test -f /etc/profile.d/linuxbrew.sh

reportResults
