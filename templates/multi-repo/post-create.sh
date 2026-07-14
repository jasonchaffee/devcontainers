#!/bin/bash
# ============================================================================
# Multi-repo devcontainer post-create — OVERLAY variant.
#
# This is NOT a standalone template. It layers on top of one of the base
# templates (java / node / python): copy this file (and this folder's
# devcontainer.json + *.code-workspace) into a NAMED config dir such as
# .devcontainer/multi-repo/ (or a portfolio name of your choosing),
# then point that config's postCreateCommand at this script.
#
# EDIT the three spots marked "EDIT:" below to match your repo set. Everything
# else is generic and safe to leave as-is.
#
# See templates/multi-repo/README.md and the "Multi-Repo Development" section
# of DEVCONTAINER.md for the full explanation of how/why this works.
# ============================================================================
set -e

# Run the base single-repo setup first (AI config projection, cert fixes, etc.).
.devcontainer/post-create.sh

# ----------------------------------------------------------------------------
# Clone any sibling repos whose mounts came up empty on first boot — either a
# fresh container-local volume (*_MOUNT_TYPE=volume) or a bind mount to a host
# path that didn't exist yet (Docker auto-creates it empty rather than failing).
# Safe no-op when the mount already contains a real checkout.
# ----------------------------------------------------------------------------
clone_if_missing() {
    local dir="$1" url="$2"
    if [ ! -d "$dir/.git" ]; then
        # Docker creates named volumes root-owned when the mount path didn't
        # exist in the image — fix ownership so git clone (as non-root) works.
        sudo chown -R "$(whoami)" "$dir" 2>/dev/null || true
        echo "Cloning $url into $dir..."
        git clone "$url" "$dir"
    fi
}

# EDIT: one line per sibling repo you mount (see devcontainer.json mounts).
clone_if_missing /workspace/repo-b https://github.com/OWNER/repo-b.git
clone_if_missing /workspace/repo-c https://github.com/OWNER/repo-c.git

# ----------------------------------------------------------------------------
# IntelliJ / JetBrains: register sibling repos as modules automatically.
# VS Code / Cursor / Antigravity use the .code-workspace file instead — this
# block is harmless there (it only writes .idea/ files JetBrains reads).
#
# Verified against real IntelliJ-generated project files (not guessed):
#   - Maven siblings (own pom.xml): add their pom.xml to THIS project's
#     .idea/misc.xml MavenProjectsManager list — IntelliJ's Maven integration
#     then generates the real module/dependency structure.
#   - Non-Maven siblings: a plain WEB_MODULE .iml placed INSIDE THAT SIBLING'S
#     OWN ROOT dir, referenced from this project's .idea/modules.xml.
#
# Both misc.xml and modules.xml are PATCHED (merge-if-missing), never
# skip-if-exists — a repo can already have a real .idea/ on disk from prior
# non-devcontainer IntelliJ use, and a skip guard would silently never add the
# sibling entries. The per-sibling .iml uses a presence guard (self-contained,
# nothing to merge).
# ----------------------------------------------------------------------------
setup_intellij_modules() {
    # EDIT: this (primary) repo's own name — the repo whose .devcontainer you open.
    local idea_dir="/workspace/repo-a/.idea"
    mkdir -p "$idea_dir"

    # EDIT: siblings that have their own pom.xml (Maven) vs. everything else.
    local maven_siblings=(repo-b)
    local plain_siblings=(repo-c)

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

    echo "IntelliJ: linked Maven siblings [${maven_siblings[*]}], registered module siblings [${plain_siblings[*]}]"
}

setup_intellij_modules
