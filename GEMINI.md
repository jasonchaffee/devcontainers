# Gemini Instructions - Development Containers

**CRITICAL: Always read `README.md` first for the project overview, structure, and basic commands.**

This file provides supplemental context and specific development conventions for maintaining this repository.

## Supplemental Context

### Environment Handling in `install.sh`
- **User Detection:** Always use the following pattern to detect the target user, as features run as root but should often install tools for the non-root user:
  ```bash
  if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
      TARGET_USER="${_REMOTE_USER}"
      TARGET_HOME=$(eval echo ~${_REMOTE_USER})
  else
      TARGET_USER="${USER:-root}"
      TARGET_HOME="${HOME:-/root}"
  fi
  ```
- **Permission Management:** When installing files into the user's home directory, ensure correct ownership: `chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.path"`.

### Testing Patterns
- **Scenario Tests:** Use `scenarios.json` to test features against multiple distributions (`alpine`, `debian`, `fedora`, `ubuntu`).
- **Path Verification:** In `test.sh`, always verify that binaries are not only present but also executable and correctly added to the `PATH`.

### Template Design
- **Mounts:** In `devcontainer.json` templates, include common mounts for `.gitconfig`, `.ssh`, and build caches (`.m2`, `.gradle`). 
- **Initialization:** Use `initializeCommand` to create host directories before they are mounted to avoid root-ownership issues on the host.
- **Dynamic Defaults:** Heavily utilize `${templateOption:optionName}` to allow users to customize their environment during template instantiation.

## Maintenance Guidelines

- **Version Updates:** When updating a feature version, ensure both `devcontainer-feature.json` and any version defaults in `templates/` or `scenarios.json` are updated accordingly.
- **Dependency Management:** Prefer `dependsOn` in `devcontainer-feature.json` for shared utilities (like `common-utils`) rather than re-implementing logic in `install.sh`.
