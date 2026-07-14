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

# Maven build-output volume (see workspaceFolder/mounts below): Docker creates
# named volumes as root-owned when the mount path doesn't already exist in the
# image, which breaks `mvn clean`/`build-info` for the non-root vscode user.
sudo chown -R "$(whoami)" "$(pwd)/target" 2>/dev/null || true

# Project read-only host AI config homes into writable container-local copies.
# Runtime data is excluded; durable state is linked back through .ai-writeback.
RSYNC_OPTS=(-a)

_project_host_dir() {
    local tool="$1" src="$2" dst="$3"
    [ -d "$src" ] || return 0
    rm -rf "$dst" 2>/dev/null || true
    mkdir -p "$dst" 2>/dev/null || return 0

    if command -v rsync >/dev/null 2>&1; then
        case "$tool" in
            claude)
                rsync "${RSYNC_OPTS[@]}" --exclude='projects/' --exclude='memory/' --exclude='plugins/cache/' --exclude='plugins/marketplaces/' --exclude='.claude/' --exclude='file-history/' --exclude='paste-cache/' --exclude='telemetry/' --exclude='shell-snapshots/' --exclude='backups/' --exclude='stats-cache.json' --exclude='cost-history.jsonl' --exclude='cost-mode' --exclude='statusline-stdin.log' --exclude='statusline-debug.log' --exclude='sessions/' --exclude='todos/' --exclude='tasks/' --exclude='teams/' --exclude='plans/' --exclude='logs/' --exclude='ide/' --exclude='downloads/' --exclude='debug/' "$src/" "$dst/" 2>/dev/null || true
                ;;
            gemini)
                rsync "${RSYNC_OPTS[@]}" --exclude='tmp/' --exclude='memory/' --exclude='antigravity/memory/' --exclude='history/' --exclude='skills.bak.*' --exclude='logs/' "$src/" "$dst/" 2>/dev/null || true
                ;;
            codex)
                rsync "${RSYNC_OPTS[@]}" --exclude='memory/' --exclude='memories/' --exclude='sessions/' --exclude='log/' --exclude='logs/' --exclude='logs_2.sqlite*' --exclude='tmp/' --exclude='.tmp/' --exclude='cache/' --exclude='plugins/cache/' --exclude='computer-use/' --exclude='ambient-suggestions/' "$src/" "$dst/" 2>/dev/null || true
                ;;
            cursor|junie|openclaude)
                rsync "${RSYNC_OPTS[@]}" --exclude='tmp/' --exclude='.tmp/' --exclude='memory/' --exclude='cache/' --exclude='history/' --exclude='logs/' --exclude='sessions/' --exclude='projects/' --exclude='extensions/' --exclude='chats/' --exclude='plugins/cache/' --exclude='plugins/marketplaces/' "$src/" "$dst/" 2>/dev/null || true
                ;;
            opencode)
                rsync "${RSYNC_OPTS[@]}" --exclude='tmp/' --exclude='memory/' --exclude='history/' --exclude='logs/' --exclude='sessions/' "$src/" "$dst/" 2>/dev/null || true
                ;;
            *)
                rsync "${RSYNC_OPTS[@]}" "$src/" "$dst/" 2>/dev/null || true
                ;;
        esac
    else
        cp -a "$src/." "$dst/" 2>/dev/null || true
    fi
}

_project_host_file() {
    local src="$1" dst="$2"
    [ -f "$src" ] || return 0
    mkdir -p "$(dirname "$dst")" 2>/dev/null || return 0
    cp -p "$src" "$dst" 2>/dev/null || true
}

_link_writeback_dir() {
    local src="$1" dst="$2"
    [ -d "$src" ] || return 0
    rm -rf "$dst" 2>/dev/null || true
    mkdir -p "$(dirname "$dst")" 2>/dev/null || return 0
    ln -s "$src" "$dst" 2>/dev/null || true
}

_link_writeback_file() {
    local src="$1" dst="$2"
    [ -e "$src" ] || return 0
    rm -f "$dst" 2>/dev/null || true
    mkdir -p "$(dirname "$dst")" 2>/dev/null || return 0
    ln -s "$src" "$dst" 2>/dev/null || true
}

_project_host_dir claude "$HOME/.claude-host" "$HOME/.claude"
_project_host_dir codex "$HOME/.codex-host" "$HOME/.codex"
_project_host_dir gemini "$HOME/.gemini-host" "$HOME/.gemini"
_project_host_dir cursor "$HOME/.cursor-host" "$HOME/.cursor"
_project_host_dir junie "$HOME/.junie-host" "$HOME/.junie"
_project_host_dir openclaude "$HOME/.openclaude-host" "$HOME/.openclaude"
_project_host_dir antigravity "$HOME/.antigravity-host" "$HOME/.antigravity"
_project_host_dir mcp-auth "$HOME/.mcp-auth-host" "$HOME/.mcp-auth"
_project_host_dir opencode "$HOME/.config/opencode-host" "$HOME/.config/opencode"
_project_host_dir gh "$HOME/.config/gh-host" "$HOME/.config/gh"
_project_host_dir gcloud "$HOME/.config/gcloud-host" "$HOME/.config/gcloud"
_project_host_file "$HOME/.claude-json-host" "$HOME/.claude.json"

_link_writeback_file "$HOME/.ai-writeback/claude-cost-history.jsonl" "$HOME/.claude/cost-history.jsonl"
_link_writeback_file "$HOME/.ai-writeback/claude-cost-mode" "$HOME/.claude/cost-mode"
_link_writeback_dir "$HOME/.ai-writeback/claude-memory" "$HOME/.claude/memory"
_link_writeback_dir "$HOME/.ai-writeback/codex-memory" "$HOME/.codex/memory"
_link_writeback_dir "$HOME/.ai-writeback/codex-memories" "$HOME/.codex/memories"
_link_writeback_dir "$HOME/.ai-writeback/gemini-memory" "$HOME/.gemini/memory"
_link_writeback_dir "$HOME/.ai-writeback/gemini-antigravity-memory" "$HOME/.gemini/antigravity/memory"
_link_writeback_dir "$HOME/.ai-writeback/cursor-memory" "$HOME/.cursor/memory"
_link_writeback_dir "$HOME/.ai-writeback/junie-memory" "$HOME/.junie/memory"
_link_writeback_dir "$HOME/.ai-writeback/openclaude-memory" "$HOME/.openclaude/memory"
_link_writeback_dir "$HOME/.ai-writeback/opencode-memory" "$HOME/.config/opencode/memory"
_link_writeback_dir "$HOME/.ai-writeback/engram-spool-vector" "$HOME/.engram/spool/vector"
_project_host_dir antidote "$HOME/.antidote-cache-host" "$HOME/.cache/antidote"

_repair_antidote_bundle() {
    local static="$HOME/.zsh_plugins.zsh"
    local bundle="$HOME/.zsh_plugins.txt"
    local antidote="$HOME/.antidote/antidote.zsh"
    local marker="$HOME/.cache/antidote/.antidote.load"
    local needs_rebuild=0
    local target

    [ -f "$bundle" ] || return 0
    [ -f "$antidote" ] || return 0

    if [ ! -f "$static" ] || [ "$static" -ot "$bundle" ]; then
        needs_rebuild=1
    else
        while IFS= read -r target; do
            case "$target" in
                \$HOME/*) target="${HOME}${target#\$HOME}" ;;
                \~/*) target="${HOME}${target#\~}" ;;
            esac
            if [ -n "$target" ] && [ ! -e "$target" ]; then
                needs_rebuild=1
                break
            fi
        done < <(sed -nE 's/^[[:space:]]*(zsh-defer[[:space:]]+)?source[[:space:]]+"([^"]+)".*/\2/p' "$static")
    fi

    [ "$needs_rebuild" -eq 1 ] || return 0
    rm -f "$static" "${static}.zwc" "$marker"
    zsh -fc 'source "$HOME/.antidote/antidote.zsh"; zstyle ":antidote:bundle" use-friendly-names "yes"; antidote load' >/dev/null 2>&1 || true
}
_repair_antidote_bundle

if [ -d "$HOME/.ai-writeback/claude-project-memory-current" ]; then
    _project_key=$(pwd -P | sed 's#[^A-Za-z0-9._-]#-#g')
    _link_writeback_dir "$HOME/.ai-writeback/claude-project-memory-current" "$HOME/.claude/projects/${_project_key}/memory"
fi

# =============================================================================
# Verify installed tools
# =============================================================================

echo ""
echo "Tool versions:"
gcloud --version 2>/dev/null | head -1
kubectl version --client 2>/dev/null | head -1
helm version 2>/dev/null
java --version 2>/dev/null | head -1
claude --version 2>/dev/null | head -1
codex --version 2>/dev/null | head -1
if command -v gemini >/dev/null 2>&1; then
    gemini --version 2>/dev/null | head -1
fi

echo ""
echo "Dev container ready!"


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
    [ -s "$src" ] || return 0
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

_dedupe_toml_tables() {
    local file="$1" prefix="$2"
    [ -f "$file" ] || return 0
    python3 - "$file" "$prefix" <<'PY' 2>/dev/null || true
import re
import sys

path, prefix = sys.argv[1], sys.argv[2]
with open(path) as f:
    lines = f.readlines()

blocks = []
current_header = None
current = []
header_re = re.compile(r'^\[([^\]]+)\]\s*$')

for line in lines:
    match = header_re.match(line)
    if match:
        if current:
            blocks.append((current_header, current))
        current_header = match.group(1)
        current = [line]
    else:
        current.append(line)
if current:
    blocks.append((current_header, current))

keep = []
seen = set()
for header, block in reversed(blocks):
    if header and header.startswith(prefix):
        if header in seen:
            continue
        seen.add(header)
    keep.append((header, block))
keep.reverse()

with open(path, "w") as f:
    for _, block in keep:
        f.writelines(block)
PY
}

_HOST=$(_detect_host_internal)

_rewrite_config_file() {
    local file="$1" tool="${2:-}"
    [ -f "$file" ] || return 0
    sed -i -E "s#http://(127\.0\.0\.1|localhost|host\.docker\.internal|host\.rancher-desktop\.internal)#http://${_HOST}#g" "$file" 2>/dev/null || true
    sed -i "s|/Users/[^/]*/\.bun/bin|/home/vscode/.bun/bin|g" "$file" 2>/dev/null || true
    sed -i "s|/Users/[^/]*/\.local/bin|/home/vscode/.local/bin|g" "$file" 2>/dev/null || true
    sed -i "s|/Users/[^/]*/\.local/share/thalamus|/home/vscode/.local/share/thalamus|g" "$file" 2>/dev/null || true
    if [ -n "$tool" ]; then
        sed -i "s|/Users/[^/]*/\.${tool}|/home/vscode/.${tool}|g" "$file" 2>/dev/null || true
    fi
    sed -i "s|/Users/[^/]*/\.config/opencode|/home/vscode/.config/opencode|g" "$file" 2>/dev/null || true
    sed -i 's|/opt/homebrew/bin|/usr/local/share/nvm/current/bin|g' "$file" 2>/dev/null || true
    sed -i 's|/opt/homebrew/sbin|/home/linuxbrew/.linuxbrew/sbin|g' "$file" 2>/dev/null || true
    sed -i 's|/usr/local/etc/openssl/certs/combined_cacerts.pem|/etc/ssl/certs/ca-certificates.crt|g' "$file" 2>/dev/null || true
    sed -i 's|/opt/homebrew/etc/openssl/certs/combined_cacerts.pem|/etc/ssl/certs/ca-certificates.crt|g' "$file" 2>/dev/null || true
    sed -i 's|/usr/local/etc/openssl@3/cert.pem|/etc/ssl/certs/ca-certificates.crt|g' "$file" 2>/dev/null || true
    sed -i 's|/opt/homebrew/etc/openssl@3/cert.pem|/etc/ssl/certs/ca-certificates.crt|g' "$file" 2>/dev/null || true
}

for _tool in claude codex gemini cursor junie openclaude; do
    _dir="$HOME/.${_tool}"
    [ -d "$_dir" ] || continue
    find "$_dir" \( -name "*.json" -o -name "*.jsonc" -o -name "*.toml" \) 2>/dev/null | while read -r _file; do
        _rewrite_config_file "$_file" "$_tool"
    done
done
if [ -d "$HOME/.config/opencode" ]; then
    find "$HOME/.config/opencode" \( -name "*.json" -o -name "*.jsonc" -o -name "*.toml" \) 2>/dev/null | while read -r _file; do
        _rewrite_config_file "$_file" opencode
    done
fi
_rewrite_config_file "$HOME/.claude.json" claude
_rewrite_config_file "$HOME/.codex/config.toml" codex

_patch_mcp_json "$HOME/.claude.json"                       "$HOME/.claude.json"                       "$_HOST"
_patch_mcp_json "$HOME/.cursor/mcp.json"                    "$HOME/.cursor/mcp.json"                    "$_HOST"
_patch_mcp_json "$HOME/.gemini/antigravity/mcp.json"        "$HOME/.gemini/antigravity/mcp.json"        "$_HOST"
_patch_mcp_json "$HOME/.gemini/antigravity/mcp_config.json" "$HOME/.gemini/antigravity/mcp_config.json" "$_HOST"
_patch_mcp_json "$HOME/.gemini/settings.json"               "$HOME/.gemini/settings.json"               "$_HOST"
_patch_mcp_json "$HOME/.openclaude/settings.json"           "$HOME/.openclaude/settings.json"           "$_HOST"
_patch_mcp_json "$HOME/.config/opencode/opencode.json"      "$HOME/.config/opencode/opencode.json"      "$_HOST"
_patch_mcp_json "$HOME/.junie/config.json"                  "$HOME/.junie/config.json"                  "$_HOST"
_patch_mcp_toml "$HOME/.codex/config.toml"                  "$_HOST"
_dedupe_toml_tables "$HOME/.codex/config.toml"              "hooks.state."
