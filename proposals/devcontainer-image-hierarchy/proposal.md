---
id: devcontainer-template-expansion
status: draft
format: rfc2119+gherkin
created: 2026-05-28
type: feature
target-specs:
  - DOCTRINE.md
---

# Proposal: Template Expansion and Missing Features

## Problem

This repo publishes devcontainer features and one template (`java`). Three gaps
limit its usefulness:

1. **Missing templates** — there is no `python` or `node` template. Python
   developers and TypeScript/JavaScript developers have no starting point.
2. **Missing features** — `uv` (fast Python package manager), `bun` (JavaScript
   runtime), and `skaffold` (local Kubernetes development) are not available as
   features, though related repos already have working implementations.
3. **Stale env var** — the `java` template passes `GOOGLE_API_KEY` to
   `remoteEnv`; the correct name for Gemini CLI is `GEMINI_API_KEY`.

The current templates + features model is the right architecture for a personal
repo: GitHub Actions auto-publishes features on every push to `main`, features are
cached after the first `devcontainer build`, and projects can mix and match exactly
what they need. No pre-built image pipeline is needed.

## Goals

1. Add `python` template for Python development projects
2. Add `node` template for TypeScript, JavaScript, and AI development projects
3. Add `uv` feature (Astral's fast Python package manager)
4. Add `bun` feature (JavaScript runtime, bundler, package manager)
5. Add `skaffold` feature (local Kubernetes development)
6. Fix `GOOGLE_API_KEY` → `GEMINI_API_KEY` across all templates
7. Establish a documented template content policy in `DOCTRINE.md`

## Non-Goals

- Pre-built Docker images or an image hierarchy
- Automated image CI/CD pipeline
- Multi-architecture feature builds (arm64 support is best-effort)

## Proposed Solution

Add three features and two templates. Update the existing `java` template.
All features follow existing conventions: multi-platform install scripts
(apt/apk/yum), bats tests, `devcontainer-feature.json` metadata.

---

## Requirements

### R-1 — `uv` feature

A `uv` feature MUST be added to `features/src/uv/` with:
- Binary install to `/usr/local/bin/uv` from the Astral official installer
- `version` option defaulting to `latest` (uv ships frequently; latest is appropriate)
- bats test: `command -v uv` and `uv --version`

The `uv` feature MUST be referenced in the `python` template and SHOULD be
referenced in the `java` template (Python tooling is often needed alongside Java).

### R-2 — `bun` feature

A `bun` feature MUST be added to `features/src/bun/` with:
- Binary download from GitHub releases (`oven-sh/bun`) to `/usr/local/bin/bun`
- Architecture detection: amd64 and arm64
- `version` option defaulting to `latest`
- bats test: `command -v bun` and `bun --version`

The `bun` feature MUST be referenced in the `node` template.
It MAY be used standalone in any project that needs Bun without the full `node` template.

### R-3 — `skaffold` feature

A `skaffold` feature MUST be added to `features/src/skaffold/` with:
- Binary download from Google Cloud Storage
  (`https://storage.googleapis.com/skaffold/releases/v{VERSION}/skaffold-linux-{amd64|arm64}`)
- `version` option defaulting to `2.20.0`
- bats test: `command -v skaffold` and `skaffold version`

The `skaffold` feature MUST be referenced (commented out as optional) in the
`java` template. It SHOULD NOT be in the default features block of any template.

### R-4 — `python` template

A `python` template MUST be created at `templates/python/` with:
- `devcontainer-template.json` (metadata, template options)
- `devcontainer.json` using `mcr.microsoft.com/devcontainers/base:ubuntu`
- Features: common-utils, python:1, github-cli, docker-outside-of-docker,
  uv, antidote, modern-cli, shell-dev, terminal-extras, http-tools,
  claude-code, codex
- IDE extensions: ms-python.python, charliermarsh.ruff, and standard tooling
- `remoteEnv` with corrected AI provider keys (see R-7)
- `post-create.sh` and `post-start.sh` lifecycle scripts
- Template options for Python version, claude-code version, gemini inclusion

### R-5 — `node` template

A `node` template MUST be created at `templates/node/` with:
- `devcontainer-template.json` (metadata, template options)
- `devcontainer.json` using `mcr.microsoft.com/devcontainers/base:ubuntu`
- Features: common-utils, node:1, github-cli, docker-outside-of-docker,
  antidote, modern-cli, shell-dev, terminal-extras, http-tools, bun,
  claude-code, codex
- IDE extensions: TypeScript, ESLint, Prettier, and standard tooling
- `remoteEnv` with corrected AI provider keys (see R-7)
- `post-create.sh` and `post-start.sh` lifecycle scripts
- Template options for Node version, Bun inclusion, claude-code version

### R-6 — Update `java` template

The existing `java` template MUST be updated to:
- Replace `GOOGLE_API_KEY` with `GEMINI_API_KEY` in `remoteEnv`
- Add `ANTHROPIC_MODEL`, `OPENAI_API_KEY`, `OPENAI_BASE_URL` to `remoteEnv`
- Reference `uv` feature (Python tooling useful alongside Java)
- List `skaffold` as a commented-out optional feature
- Align `post-create.sh` / `post-start.sh` with the `python` and `node` templates

### R-7 — Environment variable correctness

All templates MUST use the following `remoteEnv` keys for AI providers:

```json
"remoteEnv": {
  "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}",
  "ANTHROPIC_BASE_URL": "${localEnv:ANTHROPIC_BASE_URL}",
  "ANTHROPIC_AUTH_TOKEN": "${localEnv:ANTHROPIC_AUTH_TOKEN}",
  "ANTHROPIC_MODEL": "${localEnv:ANTHROPIC_MODEL}",
  "DISABLE_AUTOUPDATER": "${localEnv:DISABLE_AUTOUPDATER}",
  "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "${localEnv:CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS}",
  "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}",
  "OPENAI_BASE_URL": "${localEnv:OPENAI_BASE_URL}",
  "GEMINI_API_KEY": "${localEnv:GEMINI_API_KEY}",
  "GEMINI_BASE_URL": "${localEnv:GEMINI_BASE_URL}",
  "GOOGLE_CLOUD_PROJECT": "${localEnv:GOOGLE_CLOUD_PROJECT}",
  "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}"
}
```

Templates MUST NOT use `GOOGLE_API_KEY` — Gemini CLI uses `GEMINI_API_KEY`.

### R-8 — Feature tests

Every new feature MUST have a `features/test/<name>/test.sh` with bats checks that:
- Verify the primary binary exists (`command -v <tool>`)
- Verify the tool runs and returns a version (`<tool> --version`)
- Run successfully against `mcr.microsoft.com/devcontainers/base:ubuntu`

Features with install options MUST have a `scenarios.json` that tests at minimum:
the default install and at least one non-default option (e.g., a specific version).

### R-9 — Template tests

Each template MUST have a `templates/<name>/test-project/` directory containing a
minimal test project that can be opened with `devcontainer up` to verify the template
builds without errors. This serves as the smoke test for the template.

### R-10 — Documentation

`README.md` MUST be updated to:
- List all three templates (`java`, `python`, `node`) in the Templates section
- List the three new features (`uv`, `bun`, `skaffold`) in the Features table
- Remove or correct any reference to `GOOGLE_API_KEY`

`DOCTRINE.md` MUST reflect that this repo uses templates + features (not pre-built
images) and document the template content policy.

Each new feature SHOULD have auto-generated documentation produced by the
`devcontainers/action@v1` CI step (triggered automatically on push to `main`).

---

## Success Criteria

- A Python developer can copy `templates/python/` and open in a devcontainer
  with Python, uv, and AI tools available without manual feature configuration
- A TypeScript developer can copy `templates/node/` and open with Node.js, Bun,
  and AI tools available
- `bun`, `uv`, and `skaffold` are published to `ghcr.io/jasonchaffee/devcontainers`
  and usable as standalone features in any `devcontainer.json`
- No template passes `GOOGLE_API_KEY` — all use `GEMINI_API_KEY`

## Acceptance Criteria

```gherkin
Feature: Template expansion and missing features

  Scenario: python template provides Python development environment
    Given a developer copies templates/python/ to their project
    When they open the project in a devcontainer
    Then python3, pip, uv, gh, bat, rg, fzf, jq, and zsh SHALL be available
    And the devcontainer SHALL open without errors

  Scenario: node template provides JavaScript/TypeScript environment
    Given a developer copies templates/node/ to their project
    When they open the project in a devcontainer
    Then node, npm, and bun SHALL be available at /usr/local/bin/
    And the devcontainer SHALL open without errors

  Scenario: bun feature works standalone
    Given a devcontainer.json installs ghcr.io/jasonchaffee/devcontainers/bun:1
    When the devcontainer is built
    Then /usr/local/bin/bun SHALL exist and bun --version SHALL succeed

  Scenario: uv feature works standalone
    Given a devcontainer.json installs ghcr.io/jasonchaffee/devcontainers/uv:1
    When the devcontainer is built
    Then uv --version SHALL succeed

  Scenario: skaffold feature works standalone
    Given a devcontainer.json installs ghcr.io/jasonchaffee/devcontainers/skaffold:1
    When the devcontainer is built
    Then skaffold version SHALL succeed

  Scenario: java template uses correct env var names
    Given the java template devcontainer.json
    When remoteEnv is inspected
    Then GEMINI_API_KEY SHALL be present
    And GOOGLE_API_KEY SHALL NOT be present
```
