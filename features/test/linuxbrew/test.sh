#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "brew installed" command -v brew
check "brew prefix exists" test -d /home/linuxbrew/.linuxbrew
check "brew version runs" brew --version
check "brew repository library path exists" test -f /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/brew.sh
check "brew profile exists" test -f /etc/profile.d/linuxbrew.sh
check "brew zsh completions pass compaudit" zsh -fc 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"; autoload -Uz compaudit; compaudit'

reportResults
