---
id: doctrine
status: current
format: prose
---

# DOCTRINE — jasonchaffee/devcontainers

Governing constitution for this repository. All decisions about features, templates,
and conventions are governed here. When in doubt, read this first.

---

## Purpose

This repo publishes two things:

1. **Devcontainer features** — Installable packages for individual tools, published
   to `ghcr.io/jasonchaffee/devcontainers` automatically via GitHub Actions
2. **Templates** — Complete `devcontainer.json` configurations for specific use cases
   (Java, Python, TypeScript/Node), meant to be copied into a project and customized

The architecture is **features + templates only**. There are no pre-built Docker images
to build or maintain. GitHub Actions publishes features automatically on every push to
`main` that touches `features/src/**`. Features are cached after the first
`devcontainer build`, so subsequent container opens are fast.

---

## Templates

Templates live under `templates/<name>/` and provide a ready-to-use
`devcontainer.json` for a specific development use case. Copy a template to your
project's `.devcontainer/` folder and customize.

### Available templates

| Template | Use case |
|---|---|
| `java` | Java / Spring Boot development (Temurin, Maven/Gradle, kubectl, Helm) |
| `python` | Python development, scripting, data work |
| `node` | TypeScript, JavaScript, and AI application development |

### Template content policy

Templates SHOULD include by default:
- `common-utils` (vscode user, zsh, git, sudo)
- `modern-cli` (bat, eza, fd, ripgrep, fzf, zoxide, delta, yq)
- `shell-dev` (shellcheck, bats)
- `terminal-extras` (tmux, btop, viddy, tldr)
- `antidote` (zsh plugin manager)
- `http-tools` (xh)
- `github-cli`
- `docker-outside-of-docker`
- AI tools: `claude-code`, `codex`
- The primary language runtime for that template (Java, Python, or Node.js)
- `uv` (Python package manager, useful even in non-Python templates for tooling)

Templates SHOULD list as optional (commented-out) features:
- `gemini-cli` (optional AI tool)
- `gcloud-cli` (optional cloud tooling)
- `skaffold` (optional Kubernetes dev tool)
- `spring`, `jmeter`, `locust`, `k6` (domain-specific optional tools)
- `jetbrains` (IDE-specific)

Templates MUST include a complete `remoteEnv` block with AI provider tokens
(see Environment Variables below).

---

## Features

Features are published automatically to `ghcr.io/jasonchaffee/devcontainers` via
GitHub Actions on every push to `main`.

Feature scripts SHOULD support multiple package managers (apt, apk, yum/dnf) for
portability across base images, unless a feature explicitly declares itself Ubuntu-only.

### Available features

| Feature | Description |
|---|---|
| `antidote` | Fast Zsh plugin manager |
| `bun` | Bun JavaScript runtime, bundler, package manager |
| `claude-code` | Claude Code CLI |
| `codex` | OpenAI Codex CLI |
| `gemini-cli` | Google Gemini CLI |
| `gcloud-cli` | Google Cloud CLI with components |
| `http-tools` | xh (modern curl/httpie alternative) |
| `jetbrains` | JetBrains IDE system dependencies |
| `jmeter` | Apache JMeter load testing |
| `locust` | Python load testing framework |
| `modern-cli` | bat, eza, fd, ripgrep, zoxide, delta, fzf, yq |
| `shell-dev` | shellcheck, bats |
| `skaffold` | Skaffold for local Kubernetes development |
| `spring` | Spring Boot VS Code/IntelliJ extensions |
| `terminal-extras` | tmux, btop, viddy, ttyd, tldr |
| `uv` | Fast Python package manager (Astral) |

---

## Environment Variables

All templates MUST use these `remoteEnv` keys. IDE env var forwarding requires
a LaunchAgent on macOS for Dock/Spotlight-launched IDEs (see README.md).

```json
"remoteEnv": {
  "ANTHROPIC_API_KEY":  "${localEnv:ANTHROPIC_API_KEY}",
  "ANTHROPIC_BASE_URL": "${localEnv:ANTHROPIC_BASE_URL}",
  "ANTHROPIC_AUTH_TOKEN": "${localEnv:ANTHROPIC_AUTH_TOKEN}",
  "ANTHROPIC_MODEL":    "${localEnv:ANTHROPIC_MODEL}",
  "DISABLE_AUTOUPDATER": "${localEnv:DISABLE_AUTOUPDATER}",
  "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "${localEnv:CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS}",
  "OPENAI_API_KEY":     "${localEnv:OPENAI_API_KEY}",
  "OPENAI_BASE_URL":    "${localEnv:OPENAI_BASE_URL}",
  "GEMINI_API_KEY":     "${localEnv:GEMINI_API_KEY}",
  "GEMINI_BASE_URL":    "${localEnv:GEMINI_BASE_URL}",
  "GOOGLE_CLOUD_PROJECT": "${localEnv:GOOGLE_CLOUD_PROJECT}",
  "GITHUB_TOKEN":       "${localEnv:GITHUB_TOKEN}"
}
```

**Important:** Use `GEMINI_API_KEY` — not `GOOGLE_API_KEY`. The Gemini CLI uses
`GEMINI_API_KEY`.

---

## Directory Layout

```
features/
  src/<name>/
    devcontainer-feature.json
    install.sh
  test/<name>/
    test.sh

templates/
  java/           # Java / Spring Boot
  python/         # Python development
  node/           # TypeScript / JavaScript / AI

proposals/
  <name>/         # Active proposals
  archive/        # Shipped, abandoned, or superseded

DOCTRINE.md       # This file
README.md
```

---

## Governance

Proposed changes to template content policy, feature conventions, or tooling
assignments go through the `proposals/` workflow:

1. Create `proposals/<name>/proposal.md`
2. Self-review and approve
3. Implement
4. Archive with shipped status

Active open proposal: `proposals/devcontainer-image-hierarchy/`
