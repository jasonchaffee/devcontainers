---
status: draft
format: prose
---

# Delta: DOCTRINE.md changes from template-expansion

## What changes

`DOCTRINE.md` is the sole target spec. It was rewritten as part of this proposal
and already reflects the intended final state (features + templates model, template
content policy, canonical feature list, corrected `GEMINI_API_KEY` rule).

## Post-implementation updates

After features are published and templates are merged, update DOCTRINE.md:

**Features table** — add three new rows:

| Feature | Description |
|---|---|
| `bun` | Bun JavaScript runtime, bundler, package manager |
| `skaffold` | Skaffold for local Kubernetes development |
| `uv` | Fast Python package manager (Astral) |

**Templates table** — add two new rows:

| Template | Use case |
|---|---|
| `python` | Python development, scripting, data work |
| `node` | TypeScript, JavaScript, and AI application development |

## No other changes

The template content policy, environment variable rules (`GEMINI_API_KEY`), feature
conventions, and governance section are already correctly specified. No further changes
are expected from this implementation.
