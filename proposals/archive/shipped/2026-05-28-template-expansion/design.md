---
id: template-expansion-design
status: shipped
archived-at: 2026-05-28
format: prose
proposal: template-expansion
---

# Technical Design: Template Expansion and Missing Features

## Objective

Add three features (`uv`, `bun`, `skaffold`), two templates (`python`, `node`),
update the `java` template, and fix `remoteEnv` across all templates. All features
publish automatically via existing GitHub Actions on push to `main`.

## Scope

```
features/src/
  uv/                   # New — port from PayPal repo
  bun/                  # New — port from PayPal repo
  skaffold/             # New — port from PayPal repo

features/test/
  uv/                   # New
  bun/                  # New
  skaffold/             # New

templates/
  python/               # New
    devcontainer-template.json
    devcontainer.json
    post-create.sh
    post-start.sh
  node/                 # New
    devcontainer-template.json
    devcontainer.json
    post-create.sh
    post-start.sh
  java/
    devcontainer.json   # Update: remoteEnv fix + uv + optional skaffold

README.md               # Update: new features + templates
DOCTRINE.md             # Already current — verify only
```

## Non-Goals

- Pre-built Docker images
- scenarios.json multi-variant testing (follow-on)
- arm64 verification (best-effort via existing arch detection)

---

## Feature Designs

### `uv` feature

Port directly from `Dev/OnePayPal/devcontainers/features/src/uv/`.

**Manifest** (`devcontainer-feature.json`):
```json
{
  "id": "uv",
  "version": "1.0.0",
  "name": "uv",
  "description": "Installs uv — an extremely fast Python package manager by Astral.",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "uv version to install (e.g. '0.4.0' or 'latest')"
    }
  }
}
```

**install.sh** — identical to PayPal version:
- `UV_INSTALL_DIR=/usr/local/bin`, `UV_NO_MODIFY_PATH=1`
- Astral official installer handles all platforms

**test/uv/test.sh**:
```bash
#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "uv installed" command -v uv
check "uv version runs" uv --version
reportResults
```

---

### `bun` feature

Port from `Dev/OnePayPal/devcontainers/features/src/bun/`.

**Manifest** (`devcontainer-feature.json`):
```json
{
  "id": "bun",
  "version": "1.0.0",
  "name": "Bun",
  "description": "Installs Bun — a fast JavaScript runtime, bundler, and package manager.",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Bun version to install (e.g. '1.2.0' or 'latest')"
    }
  }
}
```

**install.sh** — identical to PayPal version:
- Architecture detection: `x64` for amd64, `aarch64` for arm64
- GitHub releases download to `/usr/local/bin/bun`
- `install -m 755` for correct permissions

**test/bun/test.sh**:
```bash
#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "bun installed" command -v bun
check "bun in /usr/local/bin" test -x /usr/local/bin/bun
check "bun version runs" bun --version
reportResults
```

---

### `skaffold` feature

Port from `Dev/OnePayPal/devcontainers/features/src/skaffold/`.

**Manifest** (`devcontainer-feature.json`):
```json
{
  "id": "skaffold",
  "version": "1.0.0",
  "name": "Skaffold",
  "description": "Installs Skaffold for local Kubernetes development and continuous deployment.",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Skaffold version (e.g. '2.20.0' or 'latest')"
    }
  }
}
```

**Key difference from PayPal version:** Default is `latest` (not pinned `2.20.0`) since
this feature is not baked into an image. Consumers who want pinned versions specify them.

**install.sh** — port from PayPal, change default version handling:
- If `latest`: resolve via `https://storage.googleapis.com/skaffold/releases/latest/VERSION`
- Otherwise: download pinned version from Google Cloud Storage

**test/skaffold/test.sh**:
```bash
#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "skaffold installed" command -v skaffold
check "skaffold version runs" skaffold version
reportResults
```

---

## Template Designs

### `python` template

**`devcontainer-template.json`** — metadata with options:
- `pythonVersion`: string, default `"3"` (passed to `ghcr.io/devcontainers/features/python:1`)
- `claudeCodeVersion`: string, default `"latest"`
- `installGemini`: boolean, default `false`

**`devcontainer.json`** features (default, non-optional):
```
ghcr.io/devcontainers/features/common-utils:2       username:vscode, installZsh:true
ghcr.io/devcontainers/features/python:1             version:${templateOption:pythonVersion}
ghcr.io/devcontainers/features/github-cli:1
ghcr.io/devcontainers/features/docker-outside-of-docker:1
ghcr.io/jasonchaffee/devcontainers/uv:1
ghcr.io/jasonchaffee/devcontainers/antidote:1
ghcr.io/jasonchaffee/devcontainers/modern-cli:1
ghcr.io/jasonchaffee/devcontainers/shell-dev:1
ghcr.io/jasonchaffee/devcontainers/terminal-extras:1
ghcr.io/jasonchaffee/devcontainers/http-tools:1
ghcr.io/jasonchaffee/devcontainers/claude-code:1   version:latest, installStatusLine:false
ghcr.io/jasonchaffee/devcontainers/codex:1         version:latest
```

Optional (commented-out):
```
ghcr.io/jasonchaffee/devcontainers/gemini-cli:1
ghcr.io/jasonchaffee/devcontainers/gcloud-cli:1
ghcr.io/grafana/devcontainer-features/k6:1
ghcr.io/jasonchaffee/devcontainers/locust:1
```

**IDE extensions**: ms-python.python, charliermarsh.ruff, ms-python.vscode-pylance,
eamodio.gitlens, esbenp.prettier-vscode, usernamehw.errorlens, timonwong.shellcheck,
jetmartin.bats, redhat.vscode-yaml, ms-azuretools.vscode-docker, anthropic.claude-code,
github.copilot, google.geminicodeassist

**`post-create.sh`** — adapt from java template:
- `git config --system safe.directory '*'`
- Cache directory setup
- Tool verification: `python3 --version`, `uv --version`

**`post-start.sh`** — copy from java template (kubeconfig rewrite, shell history)

---

### `node` template

**`devcontainer-template.json`** — metadata with options:
- `nodeVersion`: string, default `"lts"`
- `installBun`: boolean, default `true`
- `claudeCodeVersion`: string, default `"latest"`
- `installGemini`: boolean, default `false`

**`devcontainer.json`** features (default, non-optional):
```
ghcr.io/devcontainers/features/common-utils:2       username:vscode, installZsh:true
ghcr.io/devcontainers/features/node:1               version:${templateOption:nodeVersion}
ghcr.io/devcontainers/features/github-cli:1
ghcr.io/devcontainers/features/docker-outside-of-docker:1
ghcr.io/jasonchaffee/devcontainers/antidote:1
ghcr.io/jasonchaffee/devcontainers/modern-cli:1
ghcr.io/jasonchaffee/devcontainers/shell-dev:1
ghcr.io/jasonchaffee/devcontainers/terminal-extras:1
ghcr.io/jasonchaffee/devcontainers/http-tools:1
ghcr.io/jasonchaffee/devcontainers/bun:1
ghcr.io/jasonchaffee/devcontainers/claude-code:1   version:latest, installStatusLine:false
ghcr.io/jasonchaffee/devcontainers/codex:1         version:latest
```

Optional (commented-out):
```
ghcr.io/jasonchaffee/devcontainers/gemini-cli:1
ghcr.io/jasonchaffee/devcontainers/gcloud-cli:1
ghcr.io/grafana/devcontainer-features/k6:1
```

**IDE extensions**: dbaeumer.vscode-eslint, esbenp.prettier-vscode, ms-vscode.vscode-typescript-next,
bradlc.vscode-tailwindcss, eamodio.gitlens, usernamehw.errorlens, timonwong.shellcheck,
redhat.vscode-yaml, ms-azuretools.vscode-docker, anthropic.claude-code, github.copilot,
google.geminicodeassist

**`post-create.sh`** — tool verification: `node --version`, `bun --version`

---

### `java` template updates

Changes only (no structural rewrites):

1. **`remoteEnv`** — add missing keys, fix `GOOGLE_API_KEY` → `GEMINI_API_KEY`:
   - Add: `ANTHROPIC_MODEL`, `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `GEMINI_API_KEY`,
     `GEMINI_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`
   - Remove: `GOOGLE_API_KEY`

2. **Features** — add `uv`:
   ```json
   "ghcr.io/jasonchaffee/devcontainers/uv:1": {}
   ```

3. **Optional (commented-out)** — add skaffold:
   ```json
   // "ghcr.io/jasonchaffee/devcontainers/skaffold:1": {}
   ```

---

## README Update

Add to the Features table:

| Feature | Description |
|---|---|
| `bun` | Bun JavaScript runtime, bundler, package manager |
| `skaffold` | Skaffold for local Kubernetes development |
| `uv` | Fast Python package manager (Astral) |

Add to the Templates section:

### python
Python development environment with Python 3, uv, modern CLI tools, and AI assistants.

### node
TypeScript/JavaScript development with Node.js LTS, Bun, modern CLI tools, and AI assistants.

---

## Sequence

All steps are AI-executable. No manual publishing steps — GitHub Actions handles it.

1. Create `features/src/uv/` + `features/test/uv/`
2. Create `features/src/bun/` + `features/test/bun/`
3. Create `features/src/skaffold/` + `features/test/skaffold/`
4. Create `templates/python/` (4 files)
5. Create `templates/node/` (4 files)
6. Update `templates/java/devcontainer.json`
7. Update `README.md`
8. Commit and push — GitHub Actions publishes features automatically
