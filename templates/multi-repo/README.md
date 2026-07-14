# Multi-Repo Devcontainer Template (overlay)

Work on several related repos (e.g. a service + a shared library + infra) from **one** running devcontainer, with all of them visible as first-class folders/modules in your IDE.

This is an **overlay**, not a base template. It layers on top of one of the base templates (`java` / `node` / `python`) — you pick the base image, this adds the sibling mounts, the auto-clone, and the IDE wiring.

For the full rationale (why `/workspace/<repo>` layout, the two mount strategies, the combined-toolchain requirement, VS Code vs. JetBrains differences), read the **Multi-Repo Development** section of [`DEVCONTAINER.md`](../../DEVCONTAINER.md#multi-repo-development). This README is the quick copy-and-adapt path.

## What's here

| File | Purpose |
|---|---|
| `devcontainer.json` | Example multi-repo config — per-repo `mounts`, primary repo keeps its normal layout |
| `post-create.sh` | Clones any empty sibling mounts, then registers siblings as IntelliJ modules |
| `example.code-workspace` | Multi-root workspace for VS Code / Cursor / Antigravity |

## How to adopt

1. **Copy this folder** into your primary repo under a *named* config dir — keep your existing single-repo `.devcontainer/devcontainer.json` untouched:
   ```
   .devcontainer/devcontainer.json          # your existing single-repo default
   .devcontainer/multi-repo/                 # this folder (or name it for your project set)
   ```
2. **`devcontainer.json`** — set `image` to match your default config's base, or add the *union* of every mounted repo's features. Edit the `mounts` list: one entry per sibling, targeting `/workspace/<sibling-name>`.
3. **`post-create.sh`** — edit the two `EDIT:` spots: the `clone_if_missing` calls (one per sibling, with its clone URL) and, in `setup_intellij_modules`, the `idea_dir` (your primary repo name) plus `maven_siblings` (siblings that have their own `pom.xml`) vs. `plain_siblings` (everything else). If none of your repos use Maven, leave `maven_siblings` empty and list them all under `plain_siblings`.
4. **`example.code-workspace`** — list every repo as a `/workspace/<name>` folder; rename it to something meaningful.

## Switching in and out

Both the base and multi-repo configs are named configurations, so switching is just picking the other one and **rebuilding** (mounts are fixed at container creation — a restart won't change them). Nothing is destroyed: everything is bind-mounted from the host.

- **VS Code / Cursor / Antigravity:** "Dev Containers: Reopen in Container" shows a picker when more than one config exists; then open the `.code-workspace` file for the multi-root view.
- **JetBrains Gateway:** pick the config in the connection dialog; siblings appear as modules automatically (no `.code-workspace` equivalent — that's what `setup_intellij_modules` handles).
- **CLI:** `devcontainer up --config .devcontainer/multi-repo/devcontainer.json`

## Notes / gotchas

- **Every repo must be a direct child of `/workspace`** — never nested inside another repo's tree (that creates an embedded-repo `.git` mess).
- **`misc.xml` / `modules.xml` are patched, not overwritten** — safe to re-run and safe on a repo that already has its own `.idea/` on disk. Verified on a fresh JetBrains Gateway rebuild: IntelliJ imports the seed files into its external storage on first open and the modules display correctly, with zero manual IDE steps.
- **Sibling `.iml` files live in each sibling's own root** (`/workspace/<sibling>/<sibling>.iml`), not centralized in the primary repo's `.idea/` — this is what IntelliJ itself does for a non-Maven "Module from Existing Sources".
