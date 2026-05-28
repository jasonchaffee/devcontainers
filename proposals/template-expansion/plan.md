---
id: template-expansion-plan
status: draft
format: prose
---

# Implementation Plan: Template Expansion and Missing Features

Derived from `design.md`. All steps are AI-executable.
GitHub Actions auto-publishes features on every push to `main` — no manual
publishing step required.

---

## Phase 1 — New features (Steps 1–3)

### Step 1 — Create `features/src/uv/`

Port from `Dev/OnePayPal/devcontainers/features/src/uv/` with no changes.

Files:
- `devcontainer-feature.json`: id `uv`, version `1.0.0`, `version` option default `latest`
- `install.sh`: `UV_INSTALL_DIR=/usr/local/bin`, `UV_NO_MODIFY_PATH=1`, Astral installer

Create `features/test/uv/test.sh`:
```bash
#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "uv installed" command -v uv
check "uv version runs" uv --version
reportResults
```

**Verify:** `bash -n features/src/uv/install.sh`

---

### Step 2 — Create `features/src/bun/`

Port from `Dev/OnePayPal/devcontainers/features/src/bun/` with no changes.

Files:
- `devcontainer-feature.json`: id `bun`, version `1.0.0`, `version` option default `latest`
- `install.sh`: arch detection → GitHub releases → `/usr/local/bin/bun`

Create `features/test/bun/test.sh`:
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

**Verify:** `bash -n features/src/bun/install.sh`

---

### Step 3 — Create `features/src/skaffold/`

Port from `Dev/OnePayPal/devcontainers/features/src/skaffold/`. Change: resolve
`latest` via `https://storage.googleapis.com/skaffold/releases/latest/VERSION`
instead of the PayPal pinned default.

Files:
- `devcontainer-feature.json`: id `skaffold`, version `1.0.0`, `version` option default `latest`
- `install.sh`: latest resolution from GCS or pinned download

Create `features/test/skaffold/test.sh`:
```bash
#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "skaffold installed" command -v skaffold
check "skaffold version runs" skaffold version
reportResults
```

**Verify:** `bash -n features/src/skaffold/install.sh`

---

## Phase 2 — New templates (Steps 4–5)

### Step 4 — Create `templates/python/`

Four files:

**`devcontainer-template.json`** — metadata with options: `pythonVersion` (default `"3"`),
`claudeCodeVersion` (default `"latest"`), `installGemini` (default `false`)

**`devcontainer.json`** — features per design.md §python template. `remoteEnv` per
DOCTRINE.md §Environment Variables. Ports: none (Python scripts don't forward ports by
default — add a comment placeholder for `8000`).

**`post-create.sh`** — adapt from `templates/java/post-create.sh`:
- Keep: `git config safe.directory`, cache setup
- Replace tool verification: `python3 --version`, `uv --version` (drop java/kubectl/helm)

**`post-start.sh`** — copy directly from `templates/java/post-start.sh` (kubeconfig
rewrite and shell history logic is generic)

---

### Step 5 — Create `templates/node/`

Four files:

**`devcontainer-template.json`** — options: `nodeVersion` (default `"lts"`),
`installBun` (default `true`), `claudeCodeVersion` (default `"latest"`),
`installGemini` (default `false`)

**`devcontainer.json`** — features per design.md §node template. `remoteEnv` per
DOCTRINE.md §Environment Variables. Ports: `3000` (dev server), `8080`.

**`post-create.sh`** — tool verification: `node --version`, `npm --version`,
`bun --version`

**`post-start.sh`** — copy from `templates/java/post-start.sh`

---

## Phase 3 — Template update and docs (Steps 6–7)

### Step 6 — Update `templates/java/devcontainer.json`

Targeted changes only:

1. Replace `remoteEnv` with the full canonical set from DOCTRINE.md (fix
   `GOOGLE_API_KEY` → `GEMINI_API_KEY`, add `OPENAI_*`, `GEMINI_BASE_URL`,
   `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_MODEL`)
2. Add `"ghcr.io/jasonchaffee/devcontainers/uv:1": {}` to features
3. Add commented-out skaffold: `// "ghcr.io/jasonchaffee/devcontainers/skaffold:1": {}`

---

### Step 7 — Update `README.md`

Add to Features table: `uv`, `bun`, `skaffold`
Add to Templates section: `python` and `node` descriptions

---

## Phase 4 — Commit and archive (Step 8)

### Step 8 — Commit and push

```bash
git add features/src/uv/ features/test/uv/ \
        features/src/bun/ features/test/bun/ \
        features/src/skaffold/ features/test/skaffold/ \
        templates/python/ templates/node/ \
        templates/java/devcontainer.json \
        README.md \
        proposals/template-expansion/
git commit -m "feat: add uv/bun/skaffold features; add python and node templates"
git push
```

GitHub Actions publishes all three new features automatically on push to `main`.

Update `delta.md` (add uv/bun/skaffold to DOCTRINE features table, add python/node
to templates table) and run `/spec:archive --shipped` to close the proposal.

---

## Decisions

- Skaffold default: `latest` (not pinned) — this is a feature not an image, developers
  can pin in their own devcontainer.json if needed
- Test format: bats (`dev-container-features-test-lib`) — all existing tests converted
- Python template: uses official `python:1` feature (multi-platform, not Ubuntu-only)
- Node template: includes bun by default — it's the primary reason to use this template
- No test-project smoke-test directories in this phase (follow-on)
