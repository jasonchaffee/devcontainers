---
id: devcontainer-image-hierarchy
status: draft
format: rfc2119+gherkin
created: 2026-05-28
type: feature
target-specs:
  - DOCTRINE.md
---

# Proposal: DevContainer Image Hierarchy

## Problem

This repo currently publishes only devcontainer features — no pre-built images. Every
consumer `devcontainer.json` references `mcr.microsoft.com/devcontainers/base:ubuntu`
directly and installs 10–15 features from scratch on every fresh devcontainer build.

This causes:
1. Slow first-time startup — features install serially at devcontainer-build time
2. Every project declares the same feature set, creating drift and maintenance overhead
3. No documented policy for what belongs in a baked image vs. a feature, so both grow
   arbitrarily over time
4. Only one template (`java`) — no Python, Node.js/TypeScript, or AI templates exist

The `jasonchaffee/devcontainers` repo on GitHub already publishes features to
`ghcr.io/jasonchaffee/devcontainers`. The same registry can serve pre-built images,
and `devcontainer build` can bake features into images at publishing time rather than at
each developer's first container start.

## Goals

1. Publish pre-built images for Java, Python, and Node.js/TypeScript development so
   first-time `devcontainer up` requires no feature installation for universal tools
2. Reduce consumer `devcontainer.json` to: image reference + mounts + remoteEnv + IDE
   config + rapid-cadence or optional features only
3. Add `bun` as a baked tool in the `node` image and as a standalone feature
4. Add `uv`, `bun`, and `skaffold` as publishable features (ported patterns)
5. Establish a documented bake-vs-feature policy in `DOCTRINE.md`
6. Add `python` and `node` templates alongside the existing `java` template

## Non-Goals

- Automated image rebuild CI/CD (follow-on — images start with a manual `./build.sh`)
- `ai` workload image (deferred — the `node` image covers TypeScript AI development)
- Multi-architecture builds (linux/amd64 initially; arm64 is a follow-on)
- JetBrains Gateway image variants

## Proposed Solution

Introduce a single-tier image family built with `devcontainer build`:

```
mcr.microsoft.com/devcontainers/base:ubuntu
 └── core    modern-cli + shell-dev + terminal-extras + uv + gcloud + github-cli + docker
      ├── java    core + Java (Temurin 21/25) + Maven + kubectl + Helm + skaffold
      ├── python  core + Python 3.14 (deadsnakes) + uv
      └── node    core + Node.js 24 LTS + Bun
```

Consumer `devcontainer.json` references the appropriate image and adds only:
- Rapid-cadence AI tools: claude-code, codex, gemini-cli
- User-space shell tooling: antidote
- Optional/repo-specific: jmeter, locust, spring, jetbrains, k6

---

## Requirements

### R-1 — Image family

The repo MUST publish the following images to `ghcr.io/jasonchaffee/devcontainers/`:

| Image | Tag pattern | Inherits from | Primary consumers |
|---|---|---|---|
| `core` | `X.Y.Z` | `mcr.microsoft.com/devcontainers/base:ubuntu` | All consumer projects |
| `java` | `X.Y.Z` | `core:X.Y.Z` | Java / Spring Boot projects |
| `python` | `X.Y.Z` | `core:X.Y.Z` | Python projects |
| `node` | `X.Y.Z` | `core:X.Y.Z` | TypeScript / JavaScript / AI projects |

### R-2 — Core image contents

The `core` image MUST include, baked via `devcontainer build`:

- common-utils (vscode user, zsh, sudo, git)
- modern-cli: bat, eza, fd, ripgrep, fzf, zoxide, delta, yq
- shell-dev: shellcheck, bats
- terminal-extras: tmux, btop, viddy, tldr
- uv (Python package manager)
- Google Cloud CLI with gke-gcloud-auth-plugin
- github-cli
- docker-outside-of-docker
- http-tools (xh)

The `core` image MUST NOT include Java, Python (beyond what gcloud needs), Node.js, Bun,
or any workload-specific tool.

### R-3 — Java image contents

The `java` image MUST include everything in `core` plus:

- Java (Temurin distribution, version option defaulting to 21)
- Maven
- kubectl (latest stable)
- Helm (latest stable)
- skaffold

The `java` image SHOULD NOT include Python dev headers, Node.js, or Bun.

### R-4 — Python image contents

The `python` image MUST include everything in `core` plus:

- Python 3.14 (via deadsnakes PPA, pinned exact apt package version)
- uv (version upgrade over core's uv, ensuring current release)

The `python` image SHOULD NOT include Java, Node.js, or Bun.

### R-5 — Node image contents

The `node` image MUST include everything in `core` plus:

- Node.js 24 LTS
- Bun (latest stable, binary installed to `/usr/local/bin/bun`)

The `node` image SHOULD NOT include Java or Python dev headers.

### R-6 — New features

The following features MUST be added to `features/src/`:

| Feature | Description | Notes |
|---|---|---|
| `uv` | Fast Python package manager (Astral) | Port from PayPal repo |
| `bun` | Bun JavaScript runtime, bundler, package manager | Port from PayPal repo |
| `skaffold` | Skaffold for local Kubernetes development | Port from PayPal repo |

Each new feature MUST have a corresponding `features/test/<name>/test.sh`.

Bun MUST also be available as a standalone feature so projects not using the `node`
image can install it selectively.

### R-7 — Bake vs. feature policy

The policy in `DOCTRINE.md §Bake vs. Feature Policy` MUST govern all tooling decisions.
The canonical assignments table MUST be kept current as tools are added or reclassified.

### R-8 — Build strategy

All workload images MUST be built using `devcontainer build`, not raw `docker build`.

Each image directory (`images/<name>/`) MUST contain:
- `devcontainer.json` — pinned feature recipe (no floating selectors)
- `build.sh` — wraps `devcontainer build`; supports `--push` and `--push-only` flags
- `Dockerfile` — OCI labels only; MUST NOT contain `RUN`/`COPY`/`ADD` install logic

### R-9 — Versioning

Each image MUST be independently versioned with semver (`X.Y.Z`). GHCR allows tag
overwrites; floating tags (`:major`, `:latest`) MUST be updated on each release.
Exact version tag publication MUST fail the build if it fails.

### R-10 — Templates

The following templates MUST be created or updated:

| Template | Action |
|---|---|
| `templates/java/` | Update: reference `java:1.0.0`, strip baked features |
| `templates/python/` | Create: reference `python:1.0.0`, add python-specific IDE config |
| `templates/node/` | Create: reference `node:1.0.0`, add TypeScript IDE config |

### R-11 — DOCTRINE.md

The `DOCTRINE.md` (already created) MUST remain the governing constitution for all future
tooling decisions. It MUST be updated to remove `(to be created)` annotations after images
are published.

### R-12 — Environment variables

Consumer `devcontainer.json` templates MUST forward AI provider tokens in `remoteEnv`.
For non-PayPal environments, use direct API keys:

```json
"remoteEnv": {
  "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}",
  "ANTHROPIC_BASE_URL": "${localEnv:ANTHROPIC_BASE_URL}",
  "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}",
  "GEMINI_API_KEY": "${localEnv:GEMINI_API_KEY}",
  "GOOGLE_CLOUD_PROJECT": "${localEnv:GOOGLE_CLOUD_PROJECT}",
  "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}"
}
```

Note: `GEMINI_API_KEY` is the correct key name (not `GOOGLE_API_KEY`).

---

## Success Criteria

- A developer who opens a Java project using the `java` image gets a complete environment
  with no feature installation wait after the initial `devcontainer build`
- A TypeScript/AI project using the `node` image has Node.js 24 and Bun available without
  any `features` block entries for those tools
- A Python project using the `python` image has Python 3.14 and uv available at startup
- Consumer `devcontainer.json` contains only AI tools (claude-code, codex, gemini-cli),
  antidote, and any optional/repo-specific features

## Acceptance Criteria

```gherkin
Feature: DevContainer image hierarchy

  Scenario: core image provides universal tooling
    Given the core image has been built and published
    When a developer starts a devcontainer referencing core
    Then bat, rg, fd, fzf, jq, yq, gcloud, gh, docker, uv, and zsh SHALL be available
    And java, python3, node, and bun SHALL NOT be present

  Scenario: java image provides Java toolchain
    Given the java image has been built
    When a developer opens a Java project in a devcontainer
    Then java, mvn, kubectl, helm, and skaffold SHALL be available
    And no feature installation for those tools SHALL run at startup

  Scenario: python image provides Python toolchain
    Given the python image has been built
    When a developer opens a Python project in a devcontainer
    Then python3 --version SHALL report 3.14.x and uv SHALL be available
    And no feature installation for those tools SHALL run at startup

  Scenario: node image provides JavaScript/TypeScript toolchain
    Given the node image has been built
    When a developer opens a TypeScript project in a devcontainer
    Then node --version SHALL report v24.x and bun --version SHALL succeed
    And /usr/local/bin/bun SHALL exist and be executable
    And no feature installation for those tools SHALL run at startup

  Scenario: bun feature works standalone
    Given the bun feature is published to ghcr.io/jasonchaffee/devcontainers/bun:1
    When a devcontainer installs the bun feature without the node image
    Then bun SHALL be available at /usr/local/bin/bun

  Scenario: consumer devcontainer.json is minimal
    Given the java image is referenced in a project devcontainer.json
    When the features block is inspected
    Then it SHALL contain only tools satisfying the stay-as-feature criteria in DOCTRINE.md
    And it SHALL NOT declare java, maven, kubectl, helm, skaffold, or any baked tool
```

## Out of Scope

- Automated image CI/CD pipeline (manual `./build.sh` initially)
- `ai` dedicated workload image — `node` covers TypeScript AI development
- Multi-architecture (arm64) image builds
- JetBrains IDE-specific image variants
