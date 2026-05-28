#!/bin/bash
# post-create.sh - Runs ONCE after devcontainer creation
set -e

echo "Setting up devcontainer..."

# Git safe.directory — workspace is owned by a different UID than vscode
sudo git config --system --add safe.directory '*'

# Cache directories
sudo mkdir -p ~/.cache
sudo chown -R "$(whoami)" ~/.cache
mkdir -p ~/.cache/zsh ~/.cache/zsh-utils

# =============================================================================
# Verify installed tools
# =============================================================================

echo ""
echo "Tool versions:"
gcloud --version 2>/dev/null | head -1
kubectl version --client 2>/dev/null | head -1
helm version 2>/dev/null
java --version 2>/dev/null | head -1

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
    mcp['args'] = [str(a).replace('http://127.0.0.1', f'http://{host}') for a in mcp.get('args', [])]
    cmd = mcp.get('command', '')
    if cmd and '/Users/' in cmd and any(t in cmd for t in ['bun', 'node']):
        mcp['command'] = os.path.basename(cmd)
with open(os.path.expanduser('~/.claude.json'), 'w') as f:
    json.dump(d, f, indent=2)
print(f'Claude MCP URLs: 127.0.0.1 -> {host}')
" "$_host_alias"
fi

# Initialize antidote plugin cache
# Force regeneration so the cache is populated in this container.
# (The compiled ~/.zsh_plugins.zsh may reference a cache that does not
# exist in a fresh container; antidote bundle clones all plugins.)
if command -v antidote >/dev/null 2>&1 && [ -f "$HOME/.zsh_plugins.txt" ]; then
    echo "Initializing antidote plugin cache..."
    zsh -c "source \$(antidote home)/antidote.zsh && antidote bundle < $HOME/.zsh_plugins.txt > $HOME/.zsh_plugins.zsh" 2>/dev/null || \
    antidote bundle < "$HOME/.zsh_plugins.txt" > "$HOME/.zsh_plugins.zsh" 2>/dev/null || \
    echo "Warning: antidote bundle failed (non-fatal — plugins may be missing)"
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
with open(src) as f: d = json.load(f)
for mcp in d.get('mcpServers', {}).values():
    mcp['args'] = [str(a).replace('http://127.0.0.1', f'http://{host}') for a in mcp.get('args', [])]
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
