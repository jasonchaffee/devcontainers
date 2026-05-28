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
claude --version 2>/dev/null | head -1
codex --version 2>/dev/null | head -1
if command -v gemini >/dev/null 2>&1; then
    gemini --version 2>/dev/null | head -1
fi

echo ""
echo "Dev container ready!"


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
    cmd = mcp.get('command', '')
    if cmd and '/Users/' in cmd and any(t in cmd for t in ['bun', 'node']):
        mcp['command'] = os.path.basename(cmd)
with open(os.path.expanduser('~/.claude.json'), 'w') as f:
    json.dump(d, f, indent=2)
print(f'Claude MCP URLs: 127.0.0.1 -> {host}')
" "$_host_alias"
fi

# =============================================================================
# AI tool MCP configs — patch 127.0.0.1 URLs for container networking
# =============================================================================
_detect_host_internal() {
    if getent hosts host.rancher-desktop.internal >/dev/null 2>&1 || \
       ping -c1 -W1 host.rancher-desktop.internal >/dev/null 2>&1; then
        echo "host.rancher-desktop.internal"
    else
        echo "host.docker.internal"
    fi
}

_patch_mcp_json() {
    local src="$1" dst="$2" host="$3"
    [ -f "$src" ] || return 0
    python3 -c "
import json, sys, os
host = sys.argv[1]; src = sys.argv[2]; dst = sys.argv[3]
def rewrite_urls(value):
    if isinstance(value, str):
        return value.replace('http://127.0.0.1', f'http://{host}')
    if isinstance(value, list):
        return [rewrite_urls(item) for item in value]
    if isinstance(value, dict):
        return {key: rewrite_urls(item) for key, item in value.items()}
    return value
with open(src) as f: d = json.load(f)
d = rewrite_urls(d)
for mcp in d.get('mcpServers', {}).values():
    cmd = mcp.get('command', '')
    if cmd and '/Users/' in cmd and any(t in cmd for t in ['bun','node']):
        mcp['command'] = os.path.basename(cmd)
os.makedirs(os.path.dirname(dst), exist_ok=True) if os.path.dirname(dst) else None
with open(dst, 'w') as f: json.dump(d, f, indent=2)
print(f'Patched {os.path.basename(dst)}: 127.0.0.1 -> {host}')
" "$host" "$src" "$dst" 2>/dev/null || echo "Warning: could not patch $src"
}

_patch_mcp_toml() {
    local file="$1" host="$2"
    [ -f "$file" ] || return 0
    sed -i "s|http://127\.0\.0\.1|http://$host|g" "$file" && \
        echo "Patched $(basename $file): 127.0.0.1 -> $host" || \
        echo "Warning: could not patch $file"
}

_HOST=$(_detect_host_internal)
_patch_mcp_json /tmp/claude-host.json "$HOME/.claude.json" "$_HOST"
_patch_mcp_json "$HOME/.cursor/mcp.json"                    "$HOME/.cursor/mcp.json"                    "$_HOST"
_patch_mcp_json "$HOME/.gemini/antigravity/mcp.json"        "$HOME/.gemini/antigravity/mcp.json"        "$_HOST"
_patch_mcp_json "$HOME/.gemini/settings.json"               "$HOME/.gemini/settings.json"               "$_HOST"
_patch_mcp_toml "$HOME/.codex/config.toml"                  "$_HOST"
