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

## Repository Operating Facts

- Architecture is features + templates only; no pre-built images. Features publish to `ghcr.io/jasonchaffee/devcontainers` via GitHub Actions on every push to `main` touching `features/src/**`.
- Layout: `features/src/<name>/{devcontainer-feature.json,install.sh}`, `features/test/<name>/test.sh`, `templates/{java,python,node}/`, `proposals/<name>/` (active) and `proposals/archive/`.
- Feature scripts SHOULD support apt, apk, and yum/dnf unless the feature declares itself Ubuntu-only.
- Templates SHOULD include by default: `common-utils`, `modern-cli`, `shell-dev`, `terminal-extras`, `antidote`, `http-tools`, `github-cli`, `docker-outside-of-docker`, `claude-code`, `codex`, `uv`, plus the primary language runtime.
- Templates SHOULD list as commented-out optional features: `gemini-cli`, `gcloud-cli` (its `installSkaffold` option covers Skaffold), `spring`, `jmeter`, `locust`, `k6`, `jetbrains`.
- Every template MUST include a `remoteEnv` block forwarding via `${localEnv:NAME}`: `ANTHROPIC_API_KEY`, `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_MODEL`, `DISABLE_AUTOUPDATER`, `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`, `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `GEMINI_API_KEY`, `GEMINI_BASE_URL`, `GOOGLE_CLOUD_PROJECT`, `GITHUB_TOKEN`. Use `GEMINI_API_KEY`, not `GOOGLE_API_KEY`.
- Changes to template content policy, feature conventions, or tooling assignments go through `proposals/<name>/proposal.md`, then implement, then archive with shipped status.

## References
- [README.md](README.md) - Structure, features, templates, testing, development guide
