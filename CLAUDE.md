# CLAUDE.md - devcontainers

Dev container features and templates following the [Dev Container specification](https://containers.dev/).

## Commands
```bash
devcontainer features test -f <name> -p features/   # Test a feature
devcontainer features test -p features/              # Test all features
```

## Feature Conventions
- Options in JSON use camelCase, env vars in install.sh are UPPERCASE (e.g., `installZsh` -> `$INSTALLZSH`)
- Use `$_REMOTE_USER` for target user, `eval echo ~${_REMOTE_USER}` for home directory
- Set ownership with `chown -R "${TARGET_USER}:${TARGET_USER}"` after creating user files
- Clean up package manager caches (`rm -rf /var/lib/apt/lists/*`)
- Scripts must be idempotent and handle multiple package managers (apt/apk/yum)

## References
- [README.md](README.md) - Structure, features, templates, testing, development guide
