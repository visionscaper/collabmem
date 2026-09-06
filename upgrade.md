# Collaboration Memory System — Upgrade

These instructions are for you, the AI assistant. Follow them to upgrade an existing installation of the collaboration memory system to the latest version.

## Principles

1. **NEVER modify the user's episodic memory or world model content.** Notes (`notes.md`), indexes (`index.md`), the user's own documents in `docs/`, and world model files contain the user's accumulated knowledge. Only update system files: `methodology.md`, `support.md`, hooks, `.collab-config` settings, `.collab-memory-system`, the system's own copied guide `docs/troubleshoot.md` (Claude Code), and the collab-memory-system import block in the instruction file. One exception to "never modify user files": when a release adds a marker/anchor line to a user-owned file (e.g. the load-check marker atop `world/context.md`), prepend exactly that line, leaving all existing content untouched (see Step 4).
2. **If a release note mentions a structural change that could affect existing content**, flag it for the user rather than applying it automatically.
3. **Narrate every change.** Tell the user what you are updating and why.
4. **Confirm before applying.** Summarise the planned changes and ask for confirmation before modifying any files.

## Upgrade Steps

### Step 1: Compare Versions

This upgrade operates on **the current install only** — the one whose instruction file and `.collab-config` govern this session. Do not reach into other projects/installs from here: if the user has multiple installs (multiple scopes, or several teammates sharing a repo), each is upgraded separately from its own session.

1. Read the installed version from `<collab_dir>/.collab-memory-system` in the user's project, where `<collab_dir>` is the value in the project's `.collab-config` (it may be a custom path like `collab/<project>`, not literally `collab/`; a hard-coded `collab/...` will not exist for custom dirs).
2. Read the latest version from `collab/.collab-memory-system` in this repository (in the repo it is inside `collab/`, not at the repo root).
3. If the versions match, the shared memory files are current — but **do not stop yet if more than one instruction-file/hook pair points at this collab directory.** The version marker lives in the *shared* collab directory, while the instruction file (CLAUDE.md) and the hook are **per-clone**: every place that imports the collab directory has its own copy. That is the case for teammates sharing a repo (team/symlink installs), for one person's several machines sharing a memory repo, **and for multiple scopes on one machine** (e.g. a user-level `~/.claude/` install and a project-level one both importing the same collab directory). Whatever the reason, once *one* of those pairs is upgraded, the shared marker reads the new version even though the others' CLAUDE.md and hook are still old — and a plain version check would wrongly report them "up to date," leaving them without the per-clone changes (e.g. the load-check section and the updated hook). A tell-tale sign: the session-start output still contains the pre-v1.8.5 line *"Tier 1 files loaded via imports"* — or shows it *next to* the newer "should be loaded at this point. Verify" block, which means one scope is current and another is stale. Therefore: if the versions match, also confirm this install's per-clone parts are current — for the latest release, that the instruction file contains the `COLLABMEM-LOAD-CHECK` section and the hook is the current version. If they are, stop (up to date). If the shared version matches but the per-clone parts are stale, do a **per-clone catch-up**: apply only the instruction-file and hook changes (skip the shared-file copies, which were already done from another clone or scope), then run the verify probe. If both the version and the per-clone parts differ, proceed with the full upgrade below.

### Step 2: Read Release Notes

Read all sections in [`release-notes.md`](release-notes.md) between the installed version and the latest version, oldest first. This gives you the full picture of what changed and why across all intermediate versions.

### Step 3: Diff and Plan

**First ensure the clone has full history.** This step diffs against the installed version's baseline commit, so a shallow clone (`git clone --depth 1`, the natural way to grab a branch) will **silently break the customisation check below** — `git fetch <sha>` / `git cat-file` fail with "couldn't find remote ref", and the AI could then wholesale-replace a customised system file without noticing. If the clone is shallow (`git rev-parse --is-shallow-repository` returns `true`), run `git fetch --unshallow` (or re-clone without `--depth`) before proceeding.

Diff from the installed version's commit (listed in the release notes) to HEAD in this repository. Use the release notes as context to understand the changes.

Check for user customisations: diff the user's installed system files against the originals from the installed version's commit, which can be found in `release-notes.md`. Any differences indicate user customisations that must be preserved or merged during the upgrade.

Plan the upgrade as a single pass — do not apply version by version. Identify:
- System files that need replacing (e.g., `methodology.md`, hook scripts, client support files such as `clients/<client-name>/troubleshoot.md` → `<collab>/docs/`)
- Instruction-file block updates — changes to the import block between the `<!-- collab-memory-system:start/end -->` markers in the project's instruction file (e.g., the COLLABMEM-LOAD-CHECK section)
- Configuration settings that need adding or updating (e.g., new `.collab-config` entries)
- Memory data migrations — structural changes to memory files (e.g., new columns in index tables, new sections in world files, renamed or reorganised files, marker lines added to existing files). These affect the user's accumulated knowledge and require explicit approval.
- Any other changes that require user input

Summarise the planned changes for the user and ask for confirmation before proceeding. If memory data migrations are needed, explain what will change and why, and clearly distinguish them from system file updates.

### Step 4: Apply Changes

**For team/shared-knowledge installs, `git pull` the shared-knowledge repo first** (only that repo, not the code repo) so you upgrade current memory and avoid conflicts.

Apply all changes in a single pass:

1. Copy updated system files from this repository to the user's installation (e.g., `collab/methodology.md`, and the hook — note its source path may have moved between versions, see the release notes) using the `cp` command — this is more stable than copying over changes. After copying the hook, make it executable (`chmod +x`).
   - **Marker/anchor lines in user-owned memory files** (e.g. the load-check marker at the top of `world/context.md`): never replace the file — insert exactly the line specified in the release notes with an **edit tool** (not shell/`cp`, so the change is a reviewable diff), leaving the user's content untouched. **Idempotent:** if that line is already present (e.g. a re-run), skip it — do not add it twice.
   - **When refreshing the import block in the instruction file:** preserve the existing install's path adjustments (e.g. `@../collab/...` for an instruction file in `.claude/`, or absolute paths for a collab directory outside the repo without a symlink) — apply the new block *content* with the old block's *paths*, following the path rules in install.md Step 5. Copying template paths verbatim silently breaks loading on adjusted installs. **Also preserve any user additions inside the markers** — e.g. `## Methodology Domain Extensions` imports (methodology §12); refresh the block by adding/updating the system sections, not by wholesale replacement.
   - **System support files that are copies** (e.g. `<collab>/docs/troubleshoot.md` on Claude Code): copy/replace them; do NOT add a `world/index.md` entry for them (they are system files, not world knowledge — the index-every-doc rule does not apply).
2. Add any new configuration settings to `.collab-config`.
3. If memory data migrations are needed, apply them with the user's approval. Narrate each change to the user's memory files — what is being modified, why, and what the result looks like. If a migration is ambiguous or could lose information, ask the user how to proceed rather than guessing.
4. Update `<collab_dir>/.collab-memory-system` (the `collab_dir` from `.collab-config`) to the latest version.
5. **For team/shared-knowledge installs, commit and push the shared-knowledge repo** after the shared-dir files are updated (only that repo), so teammates pick up the new memory-side files.

If the user has customised a system file (e.g., added project-specific sections to `methodology.md`), flag it and ask how to proceed — do not overwrite customisations silently.

**A per-clone catch-up may target files outside the project's permitted write area.** The stale instruction-file/hook pair is often the *global* scope (`~/.claude/CLAUDE.md` and `~/.claude/hooks/`), and global config is exactly what project write-boundary rules tend to fence off. When that happens, do not treat it as a routine file copy and do not just refuse: surface it as a decision — name the files, explain that they belong to a collabmem install outside the project, and ask the user for explicit authorisation before applying (back the files up first).

**Team/symlink installs — the load fix.** If this upgrade introduces or relies on the load-check (memory imported through a symlink to a shared-knowledge repo), the imports must be allowed to resolve outside the project. Declaring the resolved shared directory via `permissions.additionalDirectories` in `.claude/settings.json` (pointing at the real target, not the symlink) states that intent through a supported mechanism and may help across harness updates — but it has been observed **not to be sufficient by itself**: on at least one Claude Code version the per-project external-includes approval (`hasClaudeMdExternalIncludesApproved: true`) was still required. **Set both, and verify with the probe** rather than assuming either alone is enough. See `clients/claude-code/troubleshoot.md`.

### Step 5: Verify

Confirm that:
- `<collab_dir>/.collab-memory-system` (per `.collab-config`) contains the latest version string
- Updated system files match the latest templates (including any newly copied support files, e.g. `<collab>/docs/troubleshoot.md`)
- Any marker/anchor lines added this release are present exactly once at the top of their files (e.g. the load-check markers atop `methodology.md` and `world/context.md`)
- The instruction file's import block contains any new sections for this release (e.g. `COLLABMEM-LOAD-CHECK`) with the existing paths and any user extensions preserved
- Any new configuration settings are present in `.collab-config`
- Hooks are updated (if applicable) and executable
- **Hook freshness (every upgrade, even when the release did not change the hook):** diff the installed hook against this version's template. Installed hooks can drift stale across releases where "hooks unchanged" held, and would otherwise never be caught. If they differ (beyond intentional user customisation), update the hook and flag it to the user.
- If memory data migrations were applied, verify the migrated files are consistent and complete

**Probe what actually loads (Claude Code).** The checks above verify files on disk; finish by verifying the harness really injects them. Run a fresh, non-interactive probe from the project directory and **show its verbatim output to the user**:

```bash
claude -p "Do NOT use any tools. From your system context ONLY: state whether a line containing COLLABMEM-MARKER- joined with METHODOLOGY, and a line containing COLLABMEM-MARKER- joined with CONTEXT, are present in your context. Answer with present/absent for the methodology marker and for the context marker — do not repeat the joined marker tokens themselves." < /dev/null
```

Show the probe's raw output verbatim — on both success and failure — then give a one-line plain-language translation. If either marker is reported absent, imports are not loading — consult `clients/claude-code/troubleshoot.md` (also copied to `<collab>/docs/troubleshoot.md`), and explain the problem and fix to the user in plain language (no jargon about markers/imports/config; offer technical detail only if the user asks). If you cannot run the probe from inside your session, ask the user to run it in a terminal from the project directory and paste the output. **A probe that fails to authenticate or errors out before answering (e.g. `401 OAuth access token has expired`, a missing CLI, a timeout) is not a load-check result** — it says nothing about the markers. Re-run it, or ask the user to run it in a terminal after re-authenticating; do not treat it as a missing marker or start diagnosing imports. Recommend the user re-run this probe after any CLI upgrade, config-directory change, machine change, or project move — these are the events that reset external-import handling.

Inform the user that the upgrade is complete and summarise what changed. The upgrade takes effect in the next session (Tier 1 imports load once at session start) — suggest a restart.

### Step 6: Support the Project (starmem)

If `.collab-config` contains no `project_starred` property, run the `starmem` procedure after the upgrade-complete message: read `collab/support.md` (in the user's installation, or from this repository if the installed version predates it) and follow it (first ask). It asks the user, on behalf of the collabmem developers, to support the project by starring the GitHub repo, and records the answer in `.collab-config`. If the property is already present, skip this step — the user has been asked before.
