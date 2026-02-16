#!/bin/bash
set -e

INSTALL="${INSTALL:-true}"
INSTALLSTATUSLINE="${INSTALLSTATUSLINE:-true}"

# Skip installation if install=false
if [ "${INSTALL}" = "false" ]; then
    echo "Skipping Claude Code CLI installation (install=false)"
    exit 0
fi

echo "Installing Claude Code CLI..."

# Dependencies (curl, ca-certificates) provided by common-utils via dependsOn

# Determine target user (features run as root, but we want to install for the remote user)
if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    TARGET_USER="${_REMOTE_USER}"
    TARGET_HOME=$(eval echo ~${_REMOTE_USER})
else
    TARGET_USER="${USER:-root}"
    TARGET_HOME="${HOME:-/root}"
fi

echo "Installing for user: ${TARGET_USER} (home: ${TARGET_HOME})"

# Install Claude Code using native installer
# The installer puts claude in ~/.claude/bin/claude
# We need to run as the target user so it installs to their home
if [ "${TARGET_USER}" != "root" ] && [ "$(id -u)" = "0" ]; then
    # Running as root but target is non-root user - use su
    su - "${TARGET_USER}" -c 'curl -fsSL https://claude.ai/install.sh | bash' || {
        echo "Warning: Native installer failed, trying alternative install..."
        # Fallback: install globally via npm if available
        if command -v npm &> /dev/null; then
            npm install -g @anthropic-ai/claude-code || true
        fi
    }
else
    # Running as target user or root is target
    curl -fsSL https://claude.ai/install.sh | bash || {
        echo "Warning: Native installer failed"
    }
fi

# Verify installation and ensure PATH is set
# The installer may put claude in ~/.local/bin or ~/.claude/bin
CLAUDE_BIN=""
if [ -x "${TARGET_HOME}/.local/bin/claude" ]; then
    CLAUDE_BIN="${TARGET_HOME}/.local/bin"
    echo "Claude Code CLI installed successfully at ${CLAUDE_BIN}/claude"
elif [ -x "${TARGET_HOME}/.claude/bin/claude" ]; then
    CLAUDE_BIN="${TARGET_HOME}/.claude/bin"
    echo "Claude Code CLI installed successfully at ${CLAUDE_BIN}/claude"
elif command -v claude &> /dev/null; then
    echo "Claude Code CLI installed successfully (global install)"
fi

# Add to PATH via profile if not already there
if [ -n "${CLAUDE_BIN}" ]; then
    PROFILE_FILE="${TARGET_HOME}/.profile"
    BIN_PATH_PATTERN=$(basename "${CLAUDE_BIN}")
    if ! grep -q "${BIN_PATH_PATTERN}" "${PROFILE_FILE}" 2>/dev/null; then
        echo "export PATH=\"${CLAUDE_BIN}:\$PATH\"" >> "${PROFILE_FILE}"
        chown "${TARGET_USER}:${TARGET_USER}" "${PROFILE_FILE}" 2>/dev/null || true
    fi
fi

if [ -z "${CLAUDE_BIN}" ] && ! command -v claude &> /dev/null; then
    echo "Warning: Claude Code CLI installation could not be verified"
fi

# Install status line feature (optional)
if [ "${INSTALLSTATUSLINE}" = "true" ]; then
    echo "Installing status line feature..."

    # Create scripts directory
    SCRIPTS_DIR="${TARGET_HOME}/.claude/scripts"
    mkdir -p "${SCRIPTS_DIR}"

    # Deploy status line Python script (jasonchaffee-statusline)
    # Get the directory where this install script is located
    FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Copy the Python script from the feature directory
    if [ -f "${FEATURE_DIR}/jasonchaffee-statusline.py" ]; then
        cp "${FEATURE_DIR}/jasonchaffee-statusline.py" "${SCRIPTS_DIR}/jasonchaffee-statusline.py"
    else
        echo "Warning: jasonchaffee-statusline.py not found in feature directory"
    fi

    chmod +x "${SCRIPTS_DIR}/jasonchaffee-statusline.py"

    # Update settings.json
    SETTINGS_FILE="${TARGET_HOME}/.claude/settings.json"

    if [ ! -f "${SETTINGS_FILE}" ]; then
        echo '{
  "$schema": "https://json.schemastore.org/claude-code-settings.json"
}' > "${SETTINGS_FILE}"
    fi

    # Merge statusLine configuration into settings.json
    # Try jq first, then python3, then fall back to simple replacement
    if command -v jq &> /dev/null; then
        jq '.statusLine = {"type": "command", "command": "python3 ~/.claude/scripts/jasonchaffee-statusline.py", "padding": 0}' \
            "${SETTINGS_FILE}" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "${SETTINGS_FILE}"
    elif command -v python3 &> /dev/null; then
        python3 << PYTHON_SCRIPT
import json

settings_file = "${SETTINGS_FILE}"

with open(settings_file, 'r') as f:
    settings = json.load(f)

settings['statusLine'] = {
    "type": "command",
    "command": "python3 ~/.claude/scripts/jasonchaffee-statusline.py",
    "padding": 0
}

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
PYTHON_SCRIPT
    else
        # Fallback: create new settings file with statusLine
        echo '{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.claude/scripts/jasonchaffee-statusline.py",
    "padding": 0
  }
}' > "${SETTINGS_FILE}"
    fi

    # Fix ownership
    chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.claude" 2>/dev/null || true

    echo "Status line feature installed successfully"
fi
