# Development Containers

A collection of development container features and templates following the [Dev Container specification](https://containers.dev/).

See [DEVCONTAINER.md](DEVCONTAINER.md) for choosing a template, multi-repo devcontainer setup, and troubleshooting.

## Structure

```
├── features/              # Dev container features
│   ├── src/               # Feature source code
│   │   ├── antidote/      # Zsh plugin manager
│   │   ├── bun/           # Bun JavaScript runtime
│   │   ├── claude-code/   # Claude Code CLI
│   │   ├── codex/         # OpenAI Codex CLI
│   │   ├── gemini-cli/    # Google Gemini CLI
│   │   ├── gcloud-cli/    # Google Cloud CLI
│   │   ├── linuxbrew/     # Homebrew on Linux
│   │   ├── locust/        # Python load testing framework
│   │   ├── modern-cli/    # Modern Unix tools (bat, eza, fd, ripgrep, etc.)
│   │   ├── shell-dev/     # Shell development tools (shellcheck, tldr)
│   │   ├── http-tools/    # HTTP clients (xh)
│   │   ├── terminal-extras/  # Terminal utilities (tmux, btop, viddy)
│   │   ├── uv/             # Fast Python package/project manager
│   │   └── jetbrains/     # JetBrains IDE support
│   └── test/              # Feature tests
└── templates/             # Dev container templates
    ├── java/              # Java template
    ├── python/            # Python template
    ├── node/              # Node.js/TypeScript template
    └── multi-repo/        # Multi-repo overlay (mounts sibling repos)
```

## Quick Start

### Use a Template

Copy a template to your project:

```bash
cp -r templates/java your-project/.devcontainer
```

Then open in VS Code/Cursor and use "Reopen in Container".

**Working across several related repos at once?** See [`templates/multi-repo/`](templates/multi-repo/) — an overlay (layered on any base template) that mounts sibling repos into one container and wires them up as folders (VS Code/Cursor) and modules (JetBrains). Full details in [DEVCONTAINER.md → Multi-Repo Development](DEVCONTAINER.md#multi-repo-development).

## Features

Each feature in `features/` can be used independently in any devcontainer.json:

```jsonc
{
  "features": {
    "ghcr.io/jasonchaffee/devcontainers/modern-cli:1": {},
    "ghcr.io/jasonchaffee/devcontainers/claude-code:1": {
      "installStatusLine": true
    }
  }
}
```

### Available Features

| Feature | Description |
|---------|-------------|
| `antidote` | Fast Zsh plugin manager |
| `bun` | Bun JavaScript runtime, bundler, test runner, and package manager |
| `claude-code` | Claude Code CLI with optional status line |
| `codex` | OpenAI Codex CLI |
| `gcloud-cli` | Google Cloud CLI with components |
| `gemini-cli` | Google Gemini CLI |
| `http-tools` | xh (modern curl/httpie) |
| `jetbrains` | JetBrains IDE dependencies |
| `jmeter` | Apache JMeter for load testing and performance measurement |
| `locust` | Python load testing framework |
| `modern-cli` | bat, eza, fd, ripgrep, zoxide, delta, fzf, yq |
| `shell-dev` | shellcheck, tldr |
| `spring` | Spring Boot tools (VS Code/IntelliJ extensions, optional Spring CLI) |
| `terminal-extras` | tmux, btop, viddy, ttyd |
| `uv` | Fast Python package and project manager (Astral) |

## Templates

Templates provide complete devcontainer configurations for specific use cases.
Copy a template to your project's `.devcontainer/` folder and open in VS Code/Cursor.

### java

Full-featured Java development environment with Java (Temurin/Zulu), Maven/Gradle,
modern CLI tools, AI coding assistants (Claude, Copilot, Gemini), and uv.

### python

Python development environment with Python 3, uv, modern CLI tools,
and AI coding assistants (Claude, Copilot, Gemini).

### node

TypeScript/JavaScript development environment with Node.js LTS, Bun, modern CLI tools,
and AI coding assistants (Claude, Copilot, Gemini).

## Development

### Creating a New Feature

1. Create `features/src/<name>/devcontainer-feature.json`:
```json
{
  "id": "my-feature",
  "version": "1.0.0",
  "name": "My Feature",
  "description": "Description of what it installs",
  "options": {}
}
```

2. Create `features/src/<name>/install.sh`:
```bash
#!/bin/bash
set -e
echo "Installing my feature..."
# Installation logic here
```

3. Create `features/test/<name>/test.sh`:
```bash
#!/bin/bash
set -e
echo "Testing my feature..."
# Verification logic here
```

### Testing Features

Install the devcontainer CLI:

```bash
npm install -g @devcontainers/cli
```

Test a specific feature:

```bash
devcontainer features test -f claude-code -p features/
```

Test all features:

```bash
devcontainer features test -p features/
```

Test with a specific base image:

```bash
# Ubuntu (default)
devcontainer features test -p features/ -i mcr.microsoft.com/devcontainers/base:ubuntu

# Debian
devcontainer features test -p features/ -i mcr.microsoft.com/devcontainers/base:debian

# Alpine
devcontainer features test -p features/ -i mcr.microsoft.com/devcontainers/base:alpine

# Fedora
devcontainer features test -p features/ -i fedora:latest
```

Skip scenario tests (use only the base image you specify):

```bash
devcontainer features test -p features/ -i devcontainers:latest --skip-scenarios
```

Test scenario variations (defined in `features/test/<name>/scenarios.json`):

```bash
# Run all scenarios for a feature
devcontainer features test -f modern-cli -p features/

# Scenarios test different options, base images, and configurations
# Example scenarios: debian, alpine, fedora, skip_install, with_ttyd, etc.
```

### Testing Templates

For local template testing, copy the template files directly:

```bash
mkdir -p test-project/.devcontainer
cp templates/java/devcontainer.json test-project/.devcontainer/
```

Build and run the container:

```bash
cd test-project
devcontainer build --workspace-folder .
devcontainer up --workspace-folder .
```

Or test in VS Code/Cursor by opening `test-project` and using "Reopen in Container".

### Testing in VS Code/Cursor

1. Copy `templates/java/devcontainer.json` to your project's `.devcontainer/` folder
2. For local testing (before features are published), change feature references from `ghcr.io/jasonchaffee/devcontainers/...` to local paths:
   ```json
   "features": {
     "../features/claude-code": { "install": true }
   }
   ```
3. Open in VS Code/Cursor → "Reopen in Container"

### Testing in JetBrains IDEs

JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm, etc.) support dev containers via JetBrains Gateway:

1. Install [JetBrains Gateway](https://www.jetbrains.com/remote-development/gateway/)
2. Copy `templates/java/devcontainer.json` to your project's `.devcontainer/` folder
3. Open JetBrains Gateway → "New Project" → "Dev Containers"
4. Select your project folder and the IDE to use
5. Gateway will build the container and connect your IDE

Alternatively, use the **Dev Containers plugin** directly in your JetBrains IDE:

1. Install the "Dev Containers" plugin from Settings → Plugins
2. Open your project with `.devcontainer/devcontainer.json`
3. Click the notification to "Reopen in Dev Container" or use File → Remote Development → Dev Containers

### Creating a New Template

1. Create `templates/<name>/devcontainer-template.json` with metadata
2. Create `templates/<name>/devcontainer.json` with the template configuration

## References

- [Dev Container Specification](https://containers.dev/)
- [Dev Container Features](https://containers.dev/implementors/features/)
- [Dev Container Templates](https://containers.dev/implementors/templates/)
