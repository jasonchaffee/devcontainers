---
id: doctrine
status: current
format: prose
---

# DOCTRINE — jasonchaffee/devcontainers

Governing constitution for this repository. All decisions about images, features,
versioning, and directory layout are governed here. When in doubt, read this first.

---

## Purpose

This repo publishes two things:

1. **Pre-built images** — Docker images with common tooling baked in, consumed by
   consumer repos' `devcontainer.json` files for fast, consistent startup
2. **Devcontainer features** — Installable packages for tools that don't belong in
   a baked image (rapid-cadence, user-space, or optional tooling)

The goal is that a developer opening any project gets a complete environment without
waiting for feature installation after the initial `devcontainer build`.

---

## Image Tier Hierarchy

Images form a single-tier family, all extending `mcr.microsoft.com/devcontainers/base:ubuntu`.
Built with `devcontainer build` so feature scripts remain the install source of truth.

```
mcr.microsoft.com/devcontainers/base:ubuntu  (upstream)
 └── core    Ubuntu + modern-cli + shell tooling + uv + gcloud + github-cli + docker
      ├── java    core + Java (Temurin) + Maven/Gradle + kubectl + Helm + skaffold
      ├── python  core + Python 3 (deadsnakes) + uv (upgraded)
      └── node    core + Node.js 24 LTS + Bun
```

**Published to:** `ghcr.io/jasonchaffee/devcontainers/<name>:<version>`

### When to use each image

| Use case | Image |
|---|---|
| Java / Spring Boot development | `java` |
| Python development / data / scripting | `python` |
| TypeScript / JavaScript / AI tooling | `node` |
| General development / data / cloud | `core` |

### Adding a new workload image

Justified only when:
- An existing tier cannot serve the use case (different primary language/toolchain)
- The use case applies to more than one project
- The toolset is stable and not better expressed as a feature

---

## Bake vs. Feature Policy

Every tool must be assigned to one bucket. This decision is permanent until this file
is updated.

### Bake into the image when ALL THREE are true

| Criterion | Question to ask |
|---|---|
| **Universality** | Is this tool used in every project that references this image tier? |
| **Stability** | Does the tool's major version change quarterly or less? |
| **System scope** | Does it install to `/usr/local/bin` or system paths — not user home? |

### Stay as a `devcontainer.json` feature when ANY ONE is true

| Criterion | Examples |
|---|---|
| **Rapid cadence** — ships weekly or more; developer should always get latest | claude-code, codex, gemini-cli |
| **User-space install** — installs to `~/.local/bin`, `~/.claude/bin`, `~/.antidote` | claude-code, antidote |
| **Optional / repo-specific** — not universal across all consumers of this image | jmeter, locust, spring, jetbrains, k6 |
| **Auth-gated** — requires interactive auth or post-install user action | Any tool needing browser login |

### Canonical assignments

| Tool | Where it lives | Reason |
|---|---|---|
| modern-cli + shell-dev + terminal-extras + uv + gcloud + github-cli | Baked → `core` | Universal, stable, system-scope |
| Java (Temurin) + Maven/Gradle + kubectl + Helm + skaffold | Baked → `java` | Universal to Java repos, stable |
| Python 3 + uv | Baked → `python` | Universal to Python repos, stable |
| Node.js 24 LTS + Bun | Baked → `node` | Universal to JS/TS repos, stable, system-scope |
| claude-code | Feature in `devcontainer.json` | Weekly releases, user-space install |
| codex | Feature in `devcontainer.json` | Weekly releases, npm global user-space |
| gemini-cli | Feature in `devcontainer.json` | Rapid cadence, optional |
| antidote | Feature in `devcontainer.json` | User-space (`~/.antidote`), `_REMOTE_USER` sensitive |
| http-tools | Feature in `devcontainer.json` | Optional, repo-specific |
| spring | Feature in `devcontainer.json` | Optional, Java-repo-specific |
| jmeter, locust, k6 | Feature in `devcontainer.json` | Optional, load-testing specific |
| jetbrains | Feature in `devcontainer.json` | Optional, IDE-specific |
| skaffold | Feature — OR baked → `java` | Universal to Java/K8s repos |

---

## Build Strategy

All workload images **must** be built with `devcontainer build`, not raw `docker build`.
Feature scripts are the single source of truth for install logic.

Each image directory (`images/<name>/`) contains:

```
images/<name>/
  devcontainer.json    # Feature recipe — input to devcontainer build
  build.sh             # Wraps devcontainer build with version tagging and push
  Dockerfile           # OCI labels only — no tool installation
```

The `Dockerfile` exists solely for OCI label injection via `ARG`/`LABEL`. It **must not**
contain `RUN`, `COPY`, or `ADD` commands that install tools.

Image recipes **must pin** all feature references and tool version options. No `latest`,
`lts`, or major-only floating selectors in baked image recipes.

---

## Features

Features are published to `ghcr.io/jasonchaffee/devcontainers` automatically by the
GitHub Actions workflow on every push to `main` that touches `features/src/**`.

Feature scripts **should** support multiple package managers (apt, apk, yum/dnf) for
portability across base images, unless the feature explicitly declares Ubuntu-only.

---

## Versioning

Each image is versioned independently with semver (`X.Y.Z`).

| Change type | Bump |
|---|---|
| Tool version updated within existing set | Patch (`Z+1`) |
| Tool added to or removed from image | Minor (`Y+1`) |
| Base image changed or breaking devcontainer interface | Major (`X+1`) |

Every release receives `:X.Y.Z`, `:X` (major floating), and `:latest` tags.
Unlike DockerHub, GHCR allows tag overwrites — floating tags are updated in place.

Exact version tag publication is required and must fail the release if it fails.
Floating tag updates are best-effort.

---

## Directory Layout

```
features/
  src/<name>/
    devcontainer-feature.json
    install.sh
  test/<name>/
    test.sh

images/
  core/
  java/
  python/
  node/

templates/
  java/         # Reference devcontainer.json for Java / Spring Boot projects
  python/       # Reference devcontainer.json for Python projects
  node/         # Reference devcontainer.json for TypeScript / JavaScript projects

proposals/
  <name>/       # Active proposals
  archive/      # Shipped, abandoned, or superseded proposals

DOCTRINE.md     # This file
```

---

## Consumer devcontainer.json Shape

A consumer repo referencing a published image should contain only:

```json
{
  "image": "ghcr.io/jasonchaffee/devcontainers/java:1.0.0",
  "mounts": [...],
  "remoteEnv": {...},
  "customizations": { "vscode": { "extensions": [...] } },
  "features": {
    "ghcr.io/jasonchaffee/devcontainers/claude-code:1": {},
    "ghcr.io/jasonchaffee/devcontainers/codex:1": {},
    "ghcr.io/jasonchaffee/devcontainers/antidote:1": {}
  }
}
```

The `features` block should contain **only** tools that satisfy the "stay as feature" criteria.
Never re-declare a tool already baked into the referenced image.

---

## Governance

Proposed changes to the image hierarchy, bake-vs-feature policy, or versioning rules
go through the `proposals/` workflow:

1. Create `proposals/<name>/proposal.md`
2. Get approval (self-review for personal repo)
3. Implement
4. Archive the proposal

Active open proposal: `proposals/devcontainer-image-hierarchy/`
