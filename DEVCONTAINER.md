# Dev Container Guide

Reference for using these templates and features. See [README.md](README.md) for structure, feature list, and how to test features/templates locally.

---

## Choosing a Template

| Use case | Template |
|---|---|
| Java / Spring Boot | `templates/java/` |
| Python | `templates/python/` |
| TypeScript / JavaScript / Node | `templates/node/` |

```bash
cp -r templates/java/. your-project/.devcontainer/
```

Then open in VS Code/Cursor and use "Reopen in Container", or see README.md for JetBrains Gateway setup.

---

## Multi-Repo Development

By default, a devcontainer mounts and opens exactly one repo — the one whose `.devcontainer/` you launched, at `/workspace/${localWorkspaceFolderBasename}` (e.g. `/workspace/my-project`). The repo name is part of the path specifically so a multi-repo config can mount related repos as siblings under the same `/workspace` prefix without changing where the primary repo lives.

Both approaches below are part of the [official Dev Containers specification](https://containers.dev/implementors/spec) — no custom tooling required.

### Option 1 — Mount the parent directory (full multi-root)

If the repos already live as siblings on disk (e.g. `~/Dev/<org>/repo-a`, `~/Dev/<org>/repo-b`), mount the parent folder instead of just one repo. The [spec](https://containers.dev/implementors/spec) notes this `workspaceMount` + `workspaceFolder` pairing is "crucial for monorepos... while working in specific sub-projects" — the same mechanism works for sibling repos, since each keeps its own `.git`.

Set this up as a **named configuration** rather than editing your default `.devcontainer/devcontainer.json` in place — the spec supports an alternate config at `.devcontainer/<folder>/devcontainer.json`:

```
.devcontainer/devcontainer.json              # single-repo (default)
.devcontainer/multi-repo/devcontainer.json   # parent-mount variant
```

Copy your existing config into `.devcontainer/multi-repo/devcontainer.json` and point `workspaceMount` at the parent directory instead of just `repo-a` (source *and* target both change — the mount target becomes bare `/workspace` since the whole parent is what's mounted now). `workspaceFolder` conveniently stays the same value either way, since `repo-a` lands at `/workspace/repo-a` regardless of whether that came from a direct per-repo mount or from being a subdirectory of the mounted parent:

```json
"workspaceMount": "source=${localWorkspaceFolder}/..,target=/workspace,type=bind,consistency=cached",
"workspaceFolder": "/workspace/repo-a"
```

`${localWorkspaceFolder}/..` is just "the parent of the repo you're opening" — no need to hardcode a home directory or org name, and it works regardless of what each developer's clone root is named. This only works if `repo-a`'s siblings genuinely share that same parent; if they don't, use Option 2 below instead.

Then add a `.code-workspace` file (VS Code / Cursor) listing each sibling as a folder root, so all repos are visible and editable side by side in one window:

```json
{
  "folders": [
    { "path": "/workspace/repo-a" },
    { "path": "/workspace/repo-b" }
  ]
}
```

Changes in any repo write straight back to the host via the bind mount — no duplication, no sync step. Keeping this as a separate named config (rather than overwriting the default) means switching back to single-repo is just picking the other configuration — see below.

### Option 2 — Additional `mounts` entries (lightweight)

Use this when the related repos **aren't** siblings on disk (different parent folders, even different git hosts) — Option 1 requires one shared parent directory; this doesn't, since each `mounts` entry is an independent path.

Copy your default `.devcontainer/devcontainer.json` into `.devcontainer/multi-repo/devcontainer.json` and just add one [`mounts`](https://containers.dev/implementors/json_reference#mounts) entry per related repo, targeting the same `/workspace/` prefix the primary repo already uses — no `workspaceMount`/`workspaceFolder` changes needed at all, since the default already puts the primary repo at `/workspace/<its-own-name>`:

```json
"mounts": [
  "source=${localEnv:REPO_B_PATH:${localWorkspaceFolder}/../repo-b},target=/workspace/repo-b,type=${localEnv:REPO_B_MOUNT_TYPE:bind}"
]
```

Two independent env-var toggles here, both using [`${localEnv:VAR:default}`](https://containers.dev/implementors/json_reference/#variables-in-devcontainerjson) — a host env var with a fallback, applied per related repo. There's no standard clone layout across developers, so neither knob should ever be a hardcoded absolute path (`${localEnv:HOME}/Dev/<org>/repo-b`) — that only works for whoever happens to clone at that exact location:

- **`REPO_B_PATH`** — where the mount pulls from. Defaults to `${localWorkspaceFolder}/../repo-b` (a plain sibling of this repo), which is right for most developers with nothing set. Override it if `repo-b` lives somewhere else on your machine (a different parent folder, a different git host) — or, if you also set `REPO_B_MOUNT_TYPE` to `volume` below, override it with a Docker volume name instead of a path.
- **`REPO_B_MOUNT_TYPE`** — how the mount is populated. Defaults to `bind`, exposing your existing local clone directly (live-editable, changes sync to the host instantly). Set it to `volume` for a container-local checkout with zero host footprint — useful if you don't have `repo-b` cloned at all. Either way, [`post-create.sh` cloning into empty mounts](#auto-cloning-into-empty-mounts) below means neither mode needs manual setup.

`consistency=cached` is intentionally omitted from this mount — it's a bind-mount-only performance hint, and this mount can be either type.

Add a `.code-workspace` file listing each `/workspace/*` path as a folder root for a proper multi-root editor view:

```json
{
  "folders": [
    { "path": "/workspace/repo-a" },
    { "path": "/workspace/repo-b" }
  ]
}
```

**Every repo must be a top-level sibling under `/workspace` — never nested inside another repo's own subfolder** (not `/workspace/repo-a/repo-b`). Nesting one repo inside another's directory puts one repo's `.git` inside another repo's working tree — an "embedded repo" git doesn't manage the way a submodule would:

- `git status`/`git add .` in the outer repo will see the nested repo as an untracked or dirty directory, and it's easy to accidentally commit its files into the wrong repo's history.
- Anything that treats the outer repo's folder as "the repo" — recursive grep, an editor's full-text search/index, a lint or build script — will silently wander into the nested repo's entire codebase, since it has no awareness of the `.git` boundary.
- It misrepresents reality: these are independent, separately-versioned repos, and nesting one inside another blurs that boundary in a way that causes real mistakes, not just clutter.

Keeping every repo as a direct child of `/workspace` (never one level deeper, inside a sibling) avoids this regardless of how many repos are in the mix.

#### Auto-cloning into empty mounts

`bind` mode requires the repo already cloned on the host — by default at the sibling-relative path, or wherever `REPO_B_PATH` points if set. `volume` mode starts out as an empty, container-local volume with nothing in it. Rather than document a manual clone step for either case, add a `.devcontainer/multi-repo/post-create.sh` that runs the default config's setup first, then clones into whichever related-repo mounts are still empty:

```bash
#!/bin/bash
set -e

# Same setup as the default single-repo config.
.devcontainer/post-create.sh

clone_if_missing() {
    local dir="$1" url="$2"
    if [ ! -d "$dir/.git" ]; then
        echo "Cloning $url into $dir..."
        git clone "$url" "$dir"
    fi
}

clone_if_missing /workspace/repo-b https://github.com/<org>/repo-b.git
```

Point `postCreateCommand` at this script instead of the default one:

```json
"postCreateCommand": ".devcontainer/multi-repo/post-create.sh"
```

This is unconditionally safe to run regardless of which mode a mount is in: a `bind` mount to an existing clone already has `.git`, so `clone_if_missing` is a no-op there; an empty `volume`, or a `bind` mount to a host path that didn't exist yet (Docker creates it empty rather than failing), both get populated automatically on first boot. `postStartCommand` doesn't need a multi-repo-specific variant — keep it pointed at the default `.devcontainer/post-start.sh`.

### Which to use

Both give a true multi-root editor view (all repos as first-class folders via a `.code-workspace` file), and neither touches `workspaceMount`/`workspaceFolder` for the primary repo — only the disk layout differs:

| | Option 1 (parent mount) | Option 2 (per-repo `mounts`) |
|---|---|---|
| Setup | Retarget `workspaceMount` to the shared parent directory | Add one `mounts` line per related repo; primary repo's config is untouched |
| Requires | Repos are siblings under one shared parent directory | Nothing — each repo's host path is independent |
| Best for | Repo set already lives under one parent folder | Repos scattered across different parent folders or git hosts |

### Switching Between Single-Repo and Multi-Repo

Both options require a **rebuild**, not just a restart — `workspaceMount` and `mounts` are Docker bind mounts fixed at container creation, so they can't be changed on a running container. Nothing is destroyed when you switch either way; everything is bind-mounted from the host, so your files are untouched regardless of which config is active.

Set up the multi-repo variant as a separate named configuration rather than hand-editing the default `devcontainer.json` back and forth:

```
.devcontainer/devcontainer.json              # single-repo (default)
.devcontainer/multi-repo/devcontainer.json   # multi-repo variant (either option)
```

Switching is then just picking the other configuration and rebuilding — no JSON editing required:

- **VS Code / Cursor:** "Dev Containers: Reopen in Container" shows a picker when more than one configuration exists.
- **CLI:** target either config explicitly:
  ```bash
  devcontainer up --config .devcontainer/devcontainer.json               # single-repo
  devcontainer up --config .devcontainer/multi-repo/devcontainer.json    # multi-repo
  ```

---

## Common Troubleshooting

### IntelliJ / JetBrains Gateway mounts project at `/IdeaProjects` instead of `/workspace/<repo-name>`

IntelliJ ignores the default workspace path unless `workspaceMount` and `workspaceFolder` are explicitly set. The templates in this repo include both — if your project's `.devcontainer/devcontainer.json` is missing them, add:

```json
"workspaceMount": "source=${localWorkspaceFolder},target=/workspace/${localWorkspaceFolderBasename},type=bind,consistency=cached",
"workspaceFolder": "/workspace/${localWorkspaceFolderBasename}"
```

Then rebuild the container.
