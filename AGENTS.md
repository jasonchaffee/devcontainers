# AI Instructions — devcontainers

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

## Environment Handling in `install.sh`

**User Detection:** Always use the following pattern to detect the target user, as features run as root but should often install tools for the non-root user:
```bash
if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    TARGET_USER="${_REMOTE_USER}"
    TARGET_HOME=$(eval echo ~${_REMOTE_USER})
else
    TARGET_USER="${USER:-root}"
    TARGET_HOME="${HOME:-/root}"
fi
```

**Permission Management:** When installing files into the user's home directory, ensure correct ownership: `chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.path"`.

## Testing Patterns
- **Scenario Tests:** Use `scenarios.json` to test features against multiple distributions (`alpine`, `debian`, `fedora`, `ubuntu`).
- **Path Verification:** In `test.sh`, always verify that binaries are not only present but also executable and correctly added to the `PATH`.

## Template Design
- **Mounts:** In `devcontainer.json` templates, include common mounts for `.gitconfig`, `.ssh`, and build caches (`.m2`, `.gradle`).
- **Initialization:** Use `initializeCommand` to create host directories before they are mounted to avoid root-ownership issues on the host.
- **Dynamic Defaults:** Heavily utilize `${templateOption:optionName}` to allow users to customize their environment during template instantiation.

## Maintenance Guidelines

- **Version Updates:** When updating a feature version, ensure both `devcontainer-feature.json` and any version defaults in `templates/` or `scenarios.json` are updated accordingly.
- **Dependency Management:** Prefer `dependsOn` in `devcontainer-feature.json` for shared utilities (like `common-utils`) rather than re-implementing logic in `install.sh`.

## References
- [README.md](README.md) - Structure, features, templates, testing, development guide
