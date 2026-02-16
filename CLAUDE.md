# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See [README.md](README.md) for structure, commands, and available features/templates.

## Repository Layout

- `images/` - Base Docker images with build scripts
- `features/` - Dev container features (each has `devcontainer-feature.json` + `install.sh`)
- `features/test/` - Test scripts for features
- `templates/` - Complete devcontainer configurations (each has `devcontainer-template.json` + `devcontainer.json`)

## Feature Conventions

- Options in JSON use camelCase, env vars in install.sh are UPPERCASE (e.g., `installZsh` → `$INSTALLZSH`)
- Use `$_REMOTE_USER` to get target user, `eval echo ~${_REMOTE_USER}` for home directory
- Set ownership with `chown -R "${TARGET_USER}:${TARGET_USER}"` after creating user files
- Clean up package manager caches (`rm -rf /var/lib/apt/lists/*`)
- Scripts must be idempotent and handle multiple package managers (apt/apk/yum)
