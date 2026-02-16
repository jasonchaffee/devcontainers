# Development Containers

A collection of development container features and templates following the [Dev Container specification](https://containers.dev/).

## Structure

```
├── features/              # Dev container features
│   ├── src/               # Feature source code
│   │   ├── antidote/      # Zsh plugin manager
│   │   ├── claude-code/   # Claude Code CLI
│   │   ├── codex/         # OpenAI Codex CLI
│   │   ├── gemini-cli/    # Google Gemini CLI
│   │   ├── gcloud-cli/    # Google Cloud CLI
│   │   ├── modern-cli/    # Modern Unix tools (bat, eza, fd, ripgrep, etc.)
│   │   ├── shell-dev/     # Shell development tools (shellcheck, tldr)
│   │   ├── http-tools/    # HTTP clients (xh)
│   │   ├── terminal-extras/  # Terminal utilities (tmux, btop, viddy)
│   │   └── jetbrains/     # JetBrains IDE support
│   └── test/              # Feature tests
└── templates/             # Dev container templates
    └── java/              # Java template
```

## Quick Start

### Use a Template

Copy a template to your project:

```bash
cp -r templates/java your-project/.devcontainer
```

Then open in VS Code/Cursor and use "Reopen in Container".

## Features

Each feature in `features/` can be used independently in any devcontainer.json:

```jsonc
{
  "features": {
    "ghcr.io/<org>/devcontainer-features/modern-cli:1": {},
    "ghcr.io/<org>/devcontainer-features/claude-code:1": {
      "installStatusLine": true
    }
  }
}
```

### Available Features

| Feature | Description |
|---------|-------------|
| `spring` | Spring Boot tools (VS Code/IntelliJ extensions, optional Spring CLI) |
| `antidote` | Fast Zsh plugin manager |
| `claude-code` | Claude Code CLI with optional status line |
| `codex` | OpenAI Codex CLI |
| `gemini-cli` | Google Gemini CLI |
| `gcloud-cli` | Google Cloud CLI with components |
| `modern-cli` | bat, eza, fd, ripgrep, zoxide, delta, fzf, yq |
| `shell-dev` | shellcheck, tldr |
| `http-tools` | xh (modern curl/httpie) |
| `terminal-extras` | tmux, btop, viddy, ttyd |
| `jetbrains` | JetBrains IDE dependencies |
| `jmeter` | Apache JMeter for load testing and performance measurement |

## Templates

Templates provide complete devcontainer configurations for specific use cases.

### java

Full-featured Java development environment with:
- Java 21 (Temurin)
- Maven/Gradle support
- Modern CLI tools
- AI coding assistants (Claude, Copilot, Gemini)
- Cloud tooling (gcloud, kubectl, terraform)
- VS Code extensions for Java development

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

Test scenario variations (defined in `features/test/<name>/scenarios.json`):

```bash
# Run all scenarios for a feature
devcontainer features test -f modern-cli -p features/

# Scenarios test different options, base images, and configurations
# Example scenarios: debian, alpine, fedora, skip_install, with_ttyd, etc.
```

### Testing Templates

Generate a project from the template:

```bash
devcontainer templates apply \
  --template-id java \
  --template-path templates/ \
  --workspace-folder ./test-project
```

Build and run the container:

```bash
cd test-project
devcontainer build --workspace-folder .
devcontainer up --workspace-folder .
```

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
