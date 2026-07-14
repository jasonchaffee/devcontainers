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

> **Copy-and-adapt starting point:** a ready-made overlay lives at [`templates/multi-repo/`](templates/multi-repo/) — an example `devcontainer.json`, the `post-create.sh` (auto-clone + IntelliJ module wiring, with the verified `misc.xml`/`modules.xml` patch logic), an example `.code-workspace`, and its own README. The rest of this section explains what those files do and why.

Both approaches below are part of the [official Dev Containers specification](https://containers.dev/implementors/spec) — no custom tooling required.

### Option 1 — Mount the parent directory (full multi-root)

If the repos already live as siblings on disk (e.g. `~/Dev/<org>/repo-a`, `~/Dev/<org>/repo-b`), mount the parent folder instead of just one repo. The [spec](https://containers.dev/implementors/spec) notes this `workspaceMount` + `workspaceFolder` pairing is "crucial for monorepos... while working in specific sub-projects" — the same mechanism works for sibling repos, since each keeps its own `.git`.

Set this up as a **named configuration** rather than editing your default `.devcontainer/devcontainer.json` in place — the spec supports an alternate config at `.devcontainer/<folder>/devcontainer.json`:

```
.devcontainer/devcontainer.json              # single-repo (default)
.devcontainer/multi-repo/devcontainer.json   # parent-mount variant
```

`multi-repo` here is just a placeholder — name the folder for whatever it actually represents once there's real content behind it (a project or team name). A generic name reads fine for an empty example; a real one is clearer once the config carries real, specific tooling.

Copy your existing config into `.devcontainer/multi-repo/devcontainer.json` and point `workspaceMount` at the parent directory instead of just `repo-a` (source *and* target both change — the mount target becomes bare `/workspace` since the whole parent is what's mounted now). `workspaceFolder` conveniently stays the same value either way, since `repo-a` lands at `/workspace/repo-a` regardless of whether that came from a direct per-repo mount or from being a subdirectory of the mounted parent:

```json
"workspaceMount": "source=${localWorkspaceFolder}/..,target=/workspace,type=bind,consistency=cached",
"workspaceFolder": "/workspace/repo-a"
```

`${localWorkspaceFolder}/..` is just "the parent of the repo you're opening" — no need to hardcode a home directory or org name, and it works regardless of what each developer's clone root is named. This only works if `repo-a`'s siblings genuinely share that same parent; if they don't, use Option 2 below instead.

Then add a `.code-workspace` file (VS Code / Cursor / Antigravity) listing each sibling as a folder root, so all repos are visible and editable side by side in one window:

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
  "source=${localEnv:DEVCONTAINER_REPO_B_PATH:../repo-b},target=/workspace/repo-b,type=${localEnv:DEVCONTAINER_REPO_B_MOUNT_TYPE:bind}"
]
```

Two independent env-var toggles here, both using [`${localEnv:VAR:default}`](https://containers.dev/implementors/json_reference/#variables-in-devcontainerjson) — a host env var with a fallback, applied per related repo. There's no standard clone layout across developers, so neither knob should ever be a hardcoded absolute path (`${localEnv:HOME}/Dev/<org>/repo-b`) — that only works for whoever happens to clone at that exact location.

**Never write `${localWorkspaceFolder}` (or any other `${...}`) inside the default portion of `${localEnv:VAR:default}`** — empirically verified (via `devcontainer read-configuration` and a live `devcontainer up`, against `@devcontainers/cli` 0.87.0) that the substitution engine can't parse a nested `${...}` there: `${localEnv:VAR:${localWorkspaceFolder}/../repo-b}` silently resolves to the garbled literal string `${localWorkspaceFolder/../repo-b}` instead of a real path, and the mount fails or binds nothing useful. A bare relative path like `../repo-b` works instead — the devcontainer CLI resolves relative bind-mount sources against the workspace folder regardless of what directory the calling IDE/CLI happened to be in when it invoked `docker run`, confirmed with a live container + `docker exec` round-trip.

- **`DEVCONTAINER_REPO_B_PATH`** — where the mount pulls from. Defaults to `../repo-b` (a plain sibling of this repo), which is right for most developers with nothing set. Override it if `repo-b` lives somewhere else on your machine (a different parent folder, a different git host) — or, if you also set `DEVCONTAINER_REPO_B_MOUNT_TYPE` to `volume` below, override it with a Docker volume name instead of a path.
- **`DEVCONTAINER_REPO_B_MOUNT_TYPE`** — how the mount is populated. Defaults to `bind`, exposing your existing local clone directly (live-editable, changes sync to the host instantly). Set it to `volume` for a container-local checkout with zero host footprint — useful if you don't have `repo-b` cloned at all. Either way, [`post-create.sh` cloning into empty mounts](#auto-cloning-into-empty-mounts) below means neither mode needs manual setup.

`consistency=cached` is intentionally omitted from this mount — it's a bind-mount-only performance hint, and this mount can be either type.

Both vars are prefixed `DEVCONTAINER_` on purpose, not just `REPO_B_*`: `${localEnv:...}` only resolves from your host environment, and GUI-launched IDEs (opened from Dock/Spotlight, not a terminal) don't automatically inherit your shell's exported variables on macOS — they need to be synced into `launchctl setenv` separately. If your setup does that sync with a script, matching every mount override to one `DEVCONTAINER_` prefix means the sync script can forward *any* variable starting with `DEVCONTAINER_` generically, instead of needing an edit every time a new repo combo adds new variable names.

Add a `.code-workspace` file (VS Code / Cursor / Antigravity) listing each `/workspace/*` path as a folder root for a proper multi-root editor view:

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

`bind` mode requires the repo already cloned on the host — by default at the sibling-relative path, or wherever `DEVCONTAINER_REPO_B_PATH` points if set. `volume` mode starts out as an empty, container-local volume with nothing in it. Rather than document a manual clone step for either case, add a `.devcontainer/multi-repo/post-create.sh` that runs the default config's setup first, then clones into whichever related-repo mounts are still empty:

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

#### The multi-repo variant needs the *union* of every mounted repo's toolchain

If the related repos use different base images (e.g. one repo's default `devcontainer.json` uses an infra/Terraform-flavored image, another uses a Java/Maven-flavored one), the multi-repo variant only gets whichever image it happens to be built from — mounting another repo's files doesn't give you that repo's build tools. Someone can browse a mounted repo's code but not actually build or validate it.

The fix is to add the *other* repos' missing features directly to the multi-repo `devcontainer.json`'s own `features` block, on top of whichever base image it already uses — features compose regardless of what the base image already has, as long as everything shares a common lineage (no OS/architecture mismatch). Check what each related repo's own local tooling actually requires (a build script's `command -v` checks are a good source of truth) rather than assuming — a repo can have real, non-obvious runtime dependencies (e.g. a validation script needing `ruby` when nothing else in the toolchain uses it).

This makes the multi-repo variant's feature set deliberately *heavier* than any single-repo default — which is itself a reason to keep it a separate named config rather than merging into any one repo's default: forcing every single-repo session to carry a combined toolchain it doesn't need is real, avoidable bloat.

### JetBrains (IntelliJ) — sibling modules instead of a workspace file

`.code-workspace` is a VS Code/Cursor/Antigravity concept — JetBrains has no equivalent multi-root workspace feature for a project opened via Gateway + Dev Containers (only JetBrains **Fleet**, a separate IDE, has a real "attach multiple folders" capability). To get the related repos to show up in the Project tree at all, register each one as a **module** instead. There's no documented recipe for this exact scenario, so the mechanism below was reverse-engineered by comparing what IntelliJ itself writes to disk when you manually add a sibling via `File > New > Module from Existing Sources`, and it depends on whether the sibling has a recognized build system:

- **Sibling with its own `pom.xml` (Maven)** — add it to *this* project's `.idea/misc.xml`, under `MavenProjectsManager`'s `originalFiles` list. IntelliJ's own Maven integration then generates the real module/dependency structure — no hand-authored `.iml` needed.
- **Sibling with no recognized build system** — IntelliJ instead expects a plain `.iml` (type `WEB_MODULE`) placed **inside that sibling's own root directory** (not centralized in this project's `.idea/`), referenced from this project's `.idea/modules.xml`. This project's own module is never self-referenced in `modules.xml` — only the *attached* siblings appear there.

Extend the same `.devcontainer/multi-repo/post-create.sh` from [Auto-cloning into empty mounts](#auto-cloning-into-empty-mounts) above with a function that generates both, keyed off which siblings are Maven-based vs. not:

```bash
setup_intellij_modules() {
    local idea_dir="/workspace/repo-a/.idea"
    mkdir -p "$idea_dir"

    local maven_siblings=(repo-b)   # has its own pom.xml
    local plain_siblings=(repo-c)   # no recognized build system

    for repo in "${plain_siblings[@]}"; do
        local iml_path="/workspace/${repo}/${repo}.iml"
        if [ ! -f "$iml_path" ]; then
            cat > "$iml_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<module type="WEB_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://\$MODULE_DIR\$" />
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
</module>
EOF
        fi
    done

    python3 - "$idea_dir" "${#maven_siblings[@]}" "${maven_siblings[@]}" "${plain_siblings[@]}" <<'PYEOF'
import sys, os
import xml.etree.ElementTree as ET

idea_dir = sys.argv[1]
n_maven = int(sys.argv[2])
maven_siblings = sys.argv[3:3 + n_maven]
plain_siblings = sys.argv[3 + n_maven:]

def load_or_create(path):
    if os.path.exists(path):
        tree = ET.parse(path)
        return tree, tree.getroot()
    root = ET.fromstring('<project version="4"></project>')
    return ET.ElementTree(root), root

# misc.xml has real pre-existing content (JDK name, external storage config)
# that must survive — patch it, don't overwrite it.
if maven_siblings:
    misc_path = os.path.join(idea_dir, "misc.xml")
    tree, root = load_or_create(misc_path)

    mpm = root.find("./component[@name='MavenProjectsManager']")
    if mpm is None:
        mpm = ET.SubElement(root, "component", {"name": "MavenProjectsManager"})
    option = mpm.find("./option[@name='originalFiles']")
    if option is None:
        option = ET.SubElement(mpm, "option", {"name": "originalFiles"})
    lst = option.find("./list")
    if lst is None:
        lst = ET.SubElement(option, "list")

    existing = {opt.get("value") for opt in lst.findall("option")}
    for sibling in maven_siblings:
        value = f"$PROJECT_DIR$/../{sibling}/pom.xml"
        if value not in existing:
            ET.SubElement(lst, "option", {"value": value})

    ET.indent(tree, space="  ")
    tree.write(misc_path, encoding="UTF-8", xml_declaration=True)

# modules.xml may already exist too (e.g. a repo with its own prior,
# non-devcontainer .idea/ on disk) — patch it the same way as misc.xml
# above; never skip just because the file is already there.
if plain_siblings:
    modules_path = os.path.join(idea_dir, "modules.xml")
    tree2, root2 = load_or_create(modules_path)

    pmm = root2.find("./component[@name='ProjectModuleManager']")
    if pmm is None:
        pmm = ET.SubElement(root2, "component", {"name": "ProjectModuleManager"})
    modules_list = pmm.find("./modules")
    if modules_list is None:
        modules_list = ET.SubElement(pmm, "modules")

    existing2 = {m.get("filepath") for m in modules_list.findall("module")}
    for sibling in plain_siblings:
        filepath = f"$PROJECT_DIR$/../{sibling}/{sibling}.iml"
        if filepath not in existing2:
            ET.SubElement(modules_list, "module", {"fileurl": f"file://{filepath}", "filepath": filepath})

    ET.indent(tree2, space="  ")
    tree2.write(modules_path, encoding="UTF-8", xml_declaration=True)
PYEOF
}

setup_intellij_modules
```

`misc.xml` and `modules.xml` are both **patched, not overwritten** — the Python step parses whatever's already there (or starts a minimal skeleton if the file doesn't exist yet) and only adds entries that aren't already present, checking existing `<option value=...>`/`<module filepath=...>` values before appending. This matters because a repo can already have a real, non-devcontainer `.idea/` sitting on disk from before this setup ever ran (both files are typically gitignored, so this is host-local state, not something git tracks) — a plain `[ ! -f modules.xml ]` skip-if-exists guard would silently never add the sibling entries in that case, even though the per-sibling `.iml` files themselves get created fine. Only the per-sibling `.iml` files use a presence guard (`[ ! -f "$iml_path" ]`) — each one is self-contained with no pre-existing content worth merging, so simple skip-if-exists is fine there.

One related failure mode either way: since these guards (and the Python patcher's dedup) check *content*, not just *file presence*, a check that instead only checked *presence* would treat leftover `.iml`/`modules.xml`/`misc.xml` files from an unrelated manual test (e.g. adding these same modules once by hand in a local, non-devcontainer IntelliJ session, which writes host-relative paths) as "already done" and block the correct, container-relative version from ever being written. If sibling modules don't show up and the script looks right, check the actual file contents at those paths before assuming the script didn't run.

**Known caveat:** on a container whose IDE backend is *already running* when these files are corrected, IntelliJ doesn't pick the change up automatically — `modules.xml` needs **Invalidate Caches / Restart**, and the `misc.xml` Maven entry needs an explicit **Reload All Maven Projects** (Maven tool window). Neither has been confirmed necessary on a genuinely fresh, never-before-opened container (where these files are already correct before Gateway's backend starts for the first time) — IntelliJ's normal first-open behavior is to scan and import automatically, so the manual nudge may only be an artifact of fixing files out from under an already-initialized backend. Treat the manual step as a fallback, not a given, until that's verified.

### Which to use

Both give a true multi-root editor view in VS Code/Cursor/Antigravity (all repos as first-class folders via a `.code-workspace` file), and neither touches `workspaceMount`/`workspaceFolder` for the primary repo — only the disk layout differs. In JetBrains, both still need the [sibling-module setup above](#jetbrains-intellij--sibling-modules-instead-of-a-workspace-file) regardless of which option you pick, since that's a separate mechanism from the mount strategy:

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

- **VS Code / Cursor / Antigravity:** "Dev Containers: Reopen in Container" shows a picker when more than one configuration exists.
- **JetBrains:** Gateway's project picker shows each `.devcontainer/<folder>/devcontainer.json` as a separate entry.
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
