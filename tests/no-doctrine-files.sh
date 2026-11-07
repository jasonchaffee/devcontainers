#!/usr/bin/env bash
# Fails if per-tool instruction files other than AGENTS.md return.
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
status=0
for f in DOCTRINE.md CLAUDE.md GEMINI.md .codex/hooks.json .cursor/hooks.json .junie/guidelines.md; do
  if [ -e "$root/$f" ]; then echo "unexpected file: $f" >&2; status=1; fi
done
[ -f "$root/AGENTS.md" ] || { echo "missing AGENTS.md" >&2; status=1; }
exit "$status"
