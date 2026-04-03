# Collaboration Memory System — Upgrade

These instructions are for you, the AI assistant. Follow them to upgrade an existing installation of the collaboration memory system to the latest version.

## Principles

1. **NEVER modify the user's episodic memory or world model content.** Notes (`notes.md`), indexes (`index.md`), docs, and world model files contain the user's accumulated knowledge. Only update system files: `methodology.md`, hooks, `.collab-config` settings, `.collab-memory-system`.
2. **If a release note mentions a structural change that could affect existing content**, flag it for the user rather than applying it automatically.
3. **Narrate every change.** Tell the user what you are updating and why.
4. **Confirm before applying.** Summarise the planned changes and ask for confirmation before modifying any files.

## Upgrade Steps

### Step 1: Compare Versions

1. Read the installed version from `collab/.collab-memory-system` in the user's project.
2. Read the latest version from `.collab-memory-system` in this repository.
3. If the versions match, inform the user that the system is already up to date and stop.

### Step 2: Read Release Notes

Read all sections in [`release-notes.md`](release-notes.md) between the installed version and the latest version, oldest first. This gives you the full picture of what changed and why across all intermediate versions.

### Step 3: Diff and Plan

Diff from the installed version's commit (listed in the release notes) to HEAD in this repository. Use the release notes as context to understand the changes.

Check for user customisations: diff the user's installed system files against the originals from the installed version's commit, which can be found in `release-notes.md`. Any differences indicate user customisations that must be preserved or merged during the upgrade.

Plan the upgrade as a single pass — do not apply version by version. Identify:
- System files that need replacing (e.g., `methodology.md`, hook scripts)
- Configuration settings that need adding or updating (e.g., new `.collab-config` entries)
- Memory data migrations — structural changes to memory files (e.g., new columns in index tables, new sections in world files, renamed or reorganised files). These affect the user's accumulated knowledge and require explicit approval.
- Any other changes that require user input

Summarise the planned changes for the user and ask for confirmation before proceeding. If memory data migrations are needed, explain what will change and why, and clearly distinguish them from system file updates.

### Step 4: Apply Changes

Apply all changes in a single pass:

1. Copy updated system files from this repository to the user's installation (e.g., `collab/methodology.md`, `.claude/hooks/collab-memory-hook.sh`).
2. Add any new configuration settings to `.collab-config`.
3. If memory data migrations are needed, apply them with the user's approval. Narrate each change to the user's memory files — what is being modified, why, and what the result looks like. If a migration is ambiguous or could lose information, ask the user how to proceed rather than guessing.
4. Update `collab/.collab-memory-system` to the latest version.

If the user has customised a system file (e.g., added project-specific sections to `methodology.md`), flag it and ask how to proceed — do not overwrite customisations silently.

### Step 5: Verify

Confirm that:
- `collab/.collab-memory-system` contains the latest version string
- Updated system files match the latest templates
- Any new configuration settings are present in `.collab-config`
- Hooks are updated (if applicable)
- If memory data migrations were applied, verify the migrated files are consistent and complete

Inform the user that the upgrade is complete and summarise what changed.
