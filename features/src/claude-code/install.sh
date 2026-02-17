#!/bin/bash
set -e

VERSION="${VERSION:-latest}"
INSTALLSTATUSLINE="${INSTALLSTATUSLINE:-true}"

echo "Installing Claude Code CLI (version: ${VERSION})..."

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

# Ensure required directories exist with correct ownership
mkdir -p "${TARGET_HOME}/.cache" "${TARGET_HOME}/.local/bin"
chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.cache" "${TARGET_HOME}/.local" 2>/dev/null || true

# Install Claude Code using native installer
# Usage: bash [stable|latest|VERSION]
INSTALL_CMD="curl -fsSL https://claude.ai/install.sh | bash -s -- ${VERSION}"

echo "Running: ${INSTALL_CMD}"
if [ "${TARGET_USER}" != "root" ] && [ "$(id -u)" = "0" ]; then
    su - "${TARGET_USER}" -c "${INSTALL_CMD}"
else
    eval "${INSTALL_CMD}"
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

# Install status line feature (optional, non-fatal if it fails)
if [ "${INSTALLSTATUSLINE}" = "true" ]; then
    echo "Installing status line feature from GitHub..."
    if curl -fsSL https://raw.githubusercontent.com/jasonchaffee/ai/main/claude/settings/statuslines/jasonchaffee/install.sh | bash; then
        chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.claude" 2>/dev/null || true
        echo "Status line installed successfully"
    else
        echo "Warning: Status line installation failed (network may be restricted). Skipping."
    fi
fi
