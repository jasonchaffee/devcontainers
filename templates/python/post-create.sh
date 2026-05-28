#!/bin/bash
# post-create.sh - Runs ONCE after devcontainer creation
set -e

echo "Setting up Python devcontainer..."

# Git safe.directory — workspace is owned by a different UID than vscode
sudo git config --system --add safe.directory '*'

# Cache directories
sudo mkdir -p ~/.cache
sudo chown -R "$(whoami)" ~/.cache
mkdir -p ~/.cache/zsh ~/.cache/zsh-utils

echo ""
echo "Tool versions:"
python3 --version 2>/dev/null || true
uv --version 2>/dev/null || true

echo ""
echo "Dev container ready!"


# =============================================================================
# AI tool MCP config — patch localhost URLs for container use
# =============================================================================
# Detects Rancher Desktop vs Docker Desktop and rewrites 127.0.0.1 MCP URLs.
# ~/.claude.json is a read-only staged mount; the patch writes a container-local copy.
_detect_host_internal() {
    if getent hosts host.rancher-desktop.internal >/dev/null 2>&1 || \
       ping -c1 -W1 host.rancher-desktop.internal >/dev/null 2>&1; then
        echo "host.rancher-desktop.internal"
    else
        echo "host.docker.internal"
    fi
}

if [ -f /tmp/claude-host.json ]; then
    _host_alias=$(_detect_host_internal)
    python3 -c "
import json, os, sys
host = sys.argv[1]
with open('/tmp/claude-host.json') as f:
    d = json.load(f)
for name, mcp in d.get('mcpServers', {}).items():
    mcp['args'] = [str(a).replace('http://127.0.0.1', f'http://{host}') for a in mcp.get('args', [])]
    cmd = mcp.get('command', '')
    if cmd and '/Users/' in cmd and any(t in cmd for t in ['bun', 'node']):
        mcp['command'] = os.path.basename(cmd)
with open(os.path.expanduser('~/.claude.json'), 'w') as f:
    json.dump(d, f, indent=2)
print(f'Claude MCP URLs: 127.0.0.1 -> {host}')
" "$_host_alias"
fi
