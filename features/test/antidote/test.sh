#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "zsh installed" command -v zsh
check "antidote directory exists" test -d "${HOME}/.antidote"
check "antidote sources successfully" zsh -c "source ${HOME}/.antidote/antidote.zsh"

reportResults
