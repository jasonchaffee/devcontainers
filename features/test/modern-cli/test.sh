#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "bat installed" command -v bat
check "eza installed" command -v eza
check "fd installed" bash -c "command -v fd || command -v fdfind"
check "ripgrep installed" command -v rg
check "zoxide installed" command -v zoxide
check "delta installed" command -v delta
check "fzf installed" command -v fzf
check "yq installed" command -v yq

reportResults
