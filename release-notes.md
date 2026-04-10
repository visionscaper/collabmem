# Release Notes

## v1.7.2

**Changes since v1.7.1 (commit `8b7cc7a`):**

- **collab/methodology.md**: New "shared-knowledge repo" definition in System Overview (Section 1) — for distributed collaboration scenarios where memory lives in a separate git repo across devices and/or users. Four new pull/push rules using this term:
  - readmem New Session: pull the shared-knowledge repo first (new step 1, "BEFORE continuing")
  - readmem How to read: pull the shared-knowledge repo before falling through to Tier 2 search — Tier 2 files on disk may have been updated remotely since session start
  - updatemem: new "Before writing updates" subsection — `git pull` before writing to keep memory current and minimise merge conflicts
  - Concurrency: replaces the previous "commit and push promptly" sentence with a symmetric "Pull before reading, push after writing" rule, explicitly tied to `readmem` and `updatemem`
- Follow-up (10-04-2026): all four pull/push rules clarified with "(ONLY the shared-knowledge repo — not the project code repo)". Trigger: AI pulled the project repo alongside the shared-knowledge repo at session start, conflating cwd with memory source-of-truth. Extra pulls aren't harmless — they may merge remote changes the user wasn't ready for. By definition the two always differ.
- Motivation: discovered on a multi-machine setup (Mac Studio + MacBook Pro) where a session almost duplicated work that the other machine had already committed. Tier 1 files loaded into context can be stale relative to the remote shared-knowledge repo.

**Upgrade from v1.7.1:**

1. Copy `collab/methodology.md` from the new version (or apply the four changes above).
2. Update `collab/.collab-memory-system` to `v1.7.2`.

## v1.7.1

**Changes since v1.7 (commit `350b90d`):**

- **collab/methodology.md**: State Management cleanup rule strengthened — resolving or removing `state.md` items now requires (MUST) writing an episodic note + index entry before removal. New "Post-update Verification" subsection in updatemem (Section 3) — four-item checklist: state resolution note, Tier 2 world index update (explicitly lists `world/domain.md`, `world/how-tos.md`, `world/factoids.md`), doc references, and episodic index entry. Makes updatemem self-contained so the AI doesn't need to remember cross-references to Section 6 during execution.

**Upgrade from v1.7:**

1. Copy `collab/methodology.md` from the new version (or apply the two changes: strengthened State Management cleanup rule, new Post-update Verification subsection in Section 3).
2. Update `collab/.collab-memory-system` to `v1.7.1`.

## v1.7

**Changes since v1.6 (commit `c56aacc`):**

- **collab/methodology.md**: Major restructuring — action-oriented structure centered on three reflection sentinel tokens (`readmem`, `updatemem`, `maintainmem`). Three-level trigger hierarchy: sentinel tokens (MUST), word cues (SHOULD), conceptual patterns (SHOULD). Session/compaction handling distributed into readmem (new session, post-compaction) and updatemem (pre-compaction). Behavioral Triggers section removed. State Management folded into World Model Protocol. Memory Maintenance Protocol added as separate section. Concurrency moved before Collaboration Protocol. Long-term collaboration framing added throughout. Amendment exception added to append-only index rule. `state.md` explicitly excluded from world model compaction.
- **README.md**: "Working with the Memory System" rewritten around sentinel tokens with examples, three trigger levels, and platform framing. Introduction updated with sentinel tokens. "What Makes This Different" platform-independence bullet strengthened. "No automatic reflection" reframed as "Automatic reflection is best-effort". Non-hook platform guidance added. "deterministic" → "precise".
- **hooks/claude-code/collab-memory-hook.sh**: `print_memory_triggers()` simplified to sentinel token reminder (replaces full trigger list). Session references use section titles instead of numbers. Bug fix: `set -e` crash when `collab_dir=` absent from config.
- **install.md**: Section references updated to use titles. "behavioral triggers" → "word cues and conceptual triggers".
- **Template files** (notes.md, index-archive.md, world/state.md, world/context.md, world/preferences.md): Section number references replaced with section titles.

**Upgrade from v1.6:**

1. Copy `collab/methodology.md` from the new version (full replacement — structure has changed significantly).
2. Copy `hooks/claude-code/collab-memory-hook.sh` from the new version.
3. Update HTML comments in template files: replace section number references with section titles (see changed template files for exact wording).
4. Update `collab/.collab-memory-system` to `v1.7`.

## v1.6

**Changes since v1.5 (commit `8971752`):**

- **README.md**: Introduction sharpened with session continuity vs cumulative collaborative understanding framing — concrete critique of tool-execution-trace memory, emphasis on discussion-centric knowledge and conceptual understanding that compounds. "What Makes This Different" section: new first bullet on collaborative knowledge vs session continuity, enriched platform-independence bullet (plain text as portable raw material). "Working with the Memory System": added elaborate docs tip for `collab/docs/`. "No automatic reflection" limitation updated — now architecturally viable via Stop hook + transcript_path + Agent SDK subagent. "What Gets Installed" moved after "How to Upgrade" and Tier 1/Tier 2 labels added to file tree. "Requirements and Compatibility" broadened: git recommended not required, any AI with file access works, Claude Cowork mentioned as likely compatible.
- **install.md**: Critical fix for import path resolution — documented that `@path` imports resolve relative to the instruction file's location, not the project root. If CLAUDE.md is in `.claude/`, paths must use `@../collab/...` to reach the project root. Imports from outside the repo root require absolute paths (security restriction). Added guidance for all cases: project root, `.claude/`, other locations, external collab directory.
- No changes to installed files (methodology, hooks, templates). Existing installations should verify their import paths resolve correctly (see install.md Step 5).

**Upgrade from v1.5:**

1. Verify your import paths: if your instruction file is in `.claude/` and uses `@collab/...` paths, these are silently failing. Change to `@../collab/...` or use absolute paths for external collab directories.
2. Update `collab/.collab-memory-system` to `v1.6`.

## v1.5

**Changes since v1.4 (commit `5ca107a`):**

- **README.md**: New "Distributed Collaboration" subsection under "How It Works" — explains team memory use case, why memory shouldn't live in the code repo (branch divergence, public repos, access control, repo churn, memory as first-class history), and two patterns (single shared-knowledge repo vs. per-project memory repo). Clarified "all files git-tracked" note to account for external shared-knowledge repo case.
- **install.md**: Major restructure for team/solo distinction:
  - New Step 2 (Solo or Team Use?) with user-facing explanation of what each choice means
  - New Step 3 (Confirm Installation Details) — now summarises Step 1/2 findings before asking for confirmation
  - Old Step 2/3 merged — customisation options updated for solo vs team cases
  - Symlink-based team pattern: `collab` symlink in code repo points to external shared-knowledge location, git-ignored, each dev creates their own after cloning
  - `.collab-config` always uses `collab_dir=collab` (relative) for both solo and team — symlink handles redirection
  - Optional `gh` assistance for creating new shared-knowledge repos
  - New Step 9 (Record Installation Note) — writes first episodic note with installation details and `.collab-config` contents, provides diagnostic test questions for new sessions
  - Symlink setup instructions for macOS/Linux, Windows PowerShell, Windows cmd
  - Step 10 (Migrate Existing Notes) — added migration note as step 6 of the migration procedure
  - Multiple clarity improvements from external review: import block caveats moved before template, platform-specific import guidance, `@<username>` derivation, gitignore asymmetry explanation, final message now conditional on migration step
- No changes to installed files (methodology, hooks, templates). Existing installations don't need to update anything.

**Upgrade from v1.4:**

No changes to installed files. Only update `collab/.collab-memory-system` to `v1.5`.

## v1.4

**Changes since v1.3 (commit `755edf2`):**

- **collab/methodology.md**: New Section 5 (Memory Growth and Sustainability) — extracted from Section 4 as a cross-cutting concern. Conceptual overview of two mechanisms: episodic index consolidation (upward) and world model compaction (downward) with tick-tock stabilisation. User approval required for all consolidation/compaction. Growth Management forward references added to Sections 3 and 4. Archive retrieval fallback added to Section 2. All sections renumbered (old 5-13 → new 6-14). All internal section references updated. Version marker still reads v1.0 (line 1) — unchanged from template.
- **collab/index-archive.md** (new): Template file for archived episodic index entries after consolidation.
- **hooks/claude-code/collab-memory-hook.sh**: Section references updated (7→8, 9→10) to match methodology renumbering.
- **install.md**: Added `index-archive.md` to repository structure, file narration list, and verification checklist (10→11 files).
- **README.md**: Added "Memory Growth and Sustainability" subsection to "How It Works". Added `index-archive.md` to repository structure. Added staleness-by-memory-type explanation to "Three Memory Types". Fixed stale limitation text about upgrade.md.

**Upgrade from v1.3:**

1. Copy updated files to your installation:
   - `collab/methodology.md` → your collab directory
   - `hooks/claude-code/collab-memory-hook.sh` → your `.claude/hooks/collab-memory-hook.sh`
2. Copy `collab/index-archive.md` from the repository
3. Update `collab/.collab-memory-system` to `v1.4`

## v1.3

**Changes since v1.2 (commit `708989e`):**

- **upgrade.md** (new): Step-by-step upgrade instructions for AI assistants. Covers version comparison, release notes reading, diffing from installed version commit to HEAD, single-pass application, user customisation detection, memory data migration handling, and verification.
- **README.md**: Added "How to Upgrade" section with human-friendly prompt and AI pointer to upgrade.md.

**Upgrade from v1.2:**

No changes to installed files, only README.md was updated and upgrade.md added. Update `collab/.collab-memory-system` to `v1.3`.

## v1.2

**Changes since v1.1 (commit `238e776`):**

- **hooks/claude-code/collab-memory-hook.sh**: Removed per-message note/world-model cue from UserPromptSubmit (alarm fatigue — demonstrably ineffective). Added `print_memory_triggers()` function with consolidated trigger list, called in all SessionStart cases (startup/clear, compact, resume). Moved "check in-context indexes" cue from per-message to session start. UserPromptSubmit now outputs timestamp only.
- **collab/methodology.md**: Section 9 rewritten — trigger table replaced with single action statement + consolidated trigger list covering both episodic and world model updates. Sections 3 and 4 now reference Section 9 for triggers (concept vs quick-reference separation). Section 3: added discussion examples to "non-trivial logical unit of work" definition (discuss → decide → implement pattern), removed duplicate "Common triggers" list. Section 11: "trigger table" → "trigger list".
- **README.md**: "Usage Tips" → "Working with the Memory System" — user positioned as primary driver of memory updates, with honest explanation of AI attention limitations. Added sub-agent reflection as future work in limitations section. "What Makes This Different" rewritten — honest about overlap with platform memory systems (in-context indexing, tiered storage, consolidation are shared concepts), refocused on genuine differentiators: knowledge richness, user-verified quality, historical preservation, multi-user, platform independence. Emphasised long-term collaboration as core value proposition. Introduction nuanced to acknowledge existing platform memory while clarifying what's still missing for long-term collaboration.
- **install.md**: Step 8 migration rewritten — bulk migration (mechanical transform + corpus-level world model extraction) as default approach. Added historical references principle (notes are historical records, paths stay as-is). Priming wording adjusted for bulk approach.

**Upgrade from v1.1:**

1. Compare changes: `git diff 238e776..HEAD` in the ai-collab-memory repo
2. Copy updated files to your installation:
   - `collab/methodology.md` → your collab directory
   - `hooks/claude-code/collab-memory-hook.sh` → your `.claude/hooks/collab-memory-hook.sh`
3. Update `collab/.collab-memory-system` to `v1.2`

## v1.1

**Changes since v1.0 (commit `7f3037c`):**

- **methodology.md**: New `#### Writing World Model Knowledge` subsection — Tier 1 quality principle, doc reference convention, Tier 2 content structuring. Configurable character cap via `.collab-config` (replaces hardcoded ~5,000). Context pressure awareness in Section 7 — AI should proactively ask user about remaining context and propose a note before compaction occurs.
- **install.md**: Default import placement changed to end of instruction file. World model seeding order. Doc consolidation step. Transition notice for migration scenarios.
- **.collab-config**: New `tier_1_max_chars=5000` setting.
- **README.md**: Context compaction warning in Usage Tips.

**Upgrade from v1.0:**

1. Compare changes: `git diff 7f3037c..HEAD` in the ai-collab-memory repo
2. Copy updated files to your installation:
   - `collab/methodology.md` → your collab directory
   - `install.md` is reference only (not installed) — no action needed unless re-installing
3. Add `tier_1_max_chars=5000` to your `.collab-config`
4. Update `collab/.collab-memory-system` to `v1.1`
