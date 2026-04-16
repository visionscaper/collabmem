# Release Notes

## v1.8.2

**Quick fixes: readmem transparency, defensive reading, domain extensions, upgrademem sentinel, index ordering.**

Five improvements from the v1.8.2–v1.9 roadmap. One planned feature (#10, collab dir comment in instruction file) was dropped as redundant — `.collab-config` already provides this information in the context window.

**Changes since v1.8.1 (commit `8b42372`):**

- **collab/methodology.md §2 (readmem):** Rewrote "Trust it before searching" paragraph. Indexes are now framed as awareness and routing mechanism, not source of truth. For non-trivial questions, AI answers from the index first then offers to check notes and other references — "the notes may change the answer, not just add detail." Fixes misinterpretation where AI treated index entries as sufficient answers.
- **collab/methodology.md §5 (Notes Protocol):** Added episodic index ordering principle — strictly chronological, ALWAYS append at bottom. Two reasons: attention proximity (recent entries closer to active conversation) and consolidation ordering (oldest-first).
- **collab/methodology.md §6 (World Model Protocol):** Added world index ordering principle — group entries by topic, not chronologically. The world index reflects current knowledge structure, not history.
- **collab/methodology.md §10 (Defensive File Reading):** Expanded from one generic pattern to principle-based guidance with text file and JSONL patterns. JSONL files (especially Claude Code session transcripts) called out as particularly dangerous. Strengthened severity: NEVER + consequence ("can crash the session and force the user to kill the process"). Common use cases for reading session transcripts added.
- **collab/methodology.md §12 (Domain Extensions):** Added import convention — extension methodologies go under `## Methodology Domain Extensions` header after the main methodology import. Heading level 3 (`###`) or deeper for consistency.
- **collab/methodology.md §13 (NEW — upgrademem):** New sentinel token. Confirms with user first (easy to confuse with `updatemem`), then clones fresh collabmem repo and follows upgrade.md. Previous Section 13 (Troubleshooting) renumbered to §14.
- **collab/.collab-memory-system**: bumped to `v1.8.2`.

**Upgrade from v1.8.1:**

The only *installed* file that changed is `collab/methodology.md`.

1. In your installation, copy `collab/methodology.md` from the new version into your collab directory.
2. Update your installation's `collab/.collab-memory-system` to `v1.8.2`.
3. No memory data migration required.

## v1.8.1

**Attention discipline for note and index writing.**

Two write-surface failures had been accumulating: (1) notes drifting toward play-by-play action bullets and invented rationale instead of conceptual substance, and (2) index rows drifting toward mini-notes instead of association pointers. Both are attention-drift failures at the point of writing — the rules existed, but attention didn't fire on them during `updatemem` execution. v1.8.1 rewrites the Notes Protocol to be purpose-driven and adds execution-surface reinforcement in `updatemem`.

**Changes since v1.8 (commit `2787535`):**

- **collab/methodology.md §5 (Notes Protocol):**
  - New **What Notes Are For** subsection — notes serve two purposes: **conceptual record** (understanding and reasoning that feeds world model derivation over time) and **concrete record** (non-trivial artefacts the episode produced — facts, parameters, short plans, drafts). Size-based rule: if an artefact is large, write a conceptual summary in the note and save the artefact to `docs/` with a reference. Notes should stay short.
  - Rewrote **Note Template** helper text. "Context" gets examples spanning conceptual and concrete triggers. "What We Did" → "What We Did / Discussed" with conceptual framing (not play-by-play). "Key Learnings" → "Key Learnings / Decisions" with explicit bullet for concrete artefacts (or references to `docs/` if large).
  - New **Guard Against Invented Content** subsection — capture what the conversation actually produced; don't add plausible-sounding rationale, imagined motivations, or reasoning chains that were never stated. Missing conceptual content is a failure; invented conceptual content is worse.
  - New **Post-write Check** subsection — three-item checklist for substantive notes: (1) conceptual completeness, (2) conceptual honesty, (3) concrete completeness. Lightweight observation notes don't need the full check.
  - **Writing Episodic Memory Index Entries** reinforced. Opening reframed around two purposes: (a) **awareness** (the row is in your context window, so you know a note exists) and (b) **association** (the row acts as an attention target linking related topics to the underlying note). New rule: **an index row is an association pointer, not a mini-note** — keep rows to roughly 1–3 sentences of distinctive terms and meaningful context, compress specifics out when a row won't fit, split into two notes if even compression isn't enough. Drift-correction guidance added. New weak/strong example pair showing a drifted mini-note row vs. a compressed association-pointer row.
- **collab/methodology.md §3 (updatemem):** Two mirror paragraphs added at the top of "What to consider capturing", referencing the exact section titles from §5 (**conceptual record**, **concrete record**, **Post-write Check**, **index row is an association pointer, not a mini-note**, **Writing Episodic Memory Index Entries**). Lexical coupling at the execution surface — the rules fire in attention at the same place the writing happens.
- **collab/.collab-memory-system**: bumped to `v1.8.1`.

**Why these are grouped:** both failures belong to the same sub-theme (attention discipline at write-time), both live in §5 and mirror into §3, and both are fixed with the same technique — explicit rules at the execution surface with lexical coupling to the operation name. The Notes Protocol overhaul and the index-entry reinforcement are one coherent change, not two.

**Upgrade from v1.8:**

The only *installed* file that changed is `collab/methodology.md`.

1. In your installation, copy `collab/methodology.md` from the new version into your collab directory.
2. Update your installation's `collab/.collab-memory-system` to `v1.8.1`.
3. No memory data migration required.

## v1.8

**Project renamed: `ai-collab-memory` → `collabmem`.**

The GitHub repository was renamed from `visionscaper/ai-collab-memory` to `visionscaper/collabmem`. GitHub auto-redirects the old URLs (web and `git clone` over HTTPS/SSH), so existing installations and external links continue to work. No code-level identifiers were changed: the `collab-memory-system` marker file, the `collab-memory-` hook prefix, the `<!-- collab-memory-system:start --> / <!-- collab-memory-system:end -->` import markers, and the `.collab-config` file all keep their existing names. This is intentional — only the project name changes, the in-system identifiers stay stable so existing installations don't break.

**Why the rename:** the new name fits the existing sentinel vocabulary (`readmem` / `updatemem` / `maintainmem` / `collabmem`) and foregrounds *collaboration* as the primary thing the system enables, with memory as the substrate. Dropping "AI" from the name is a deliberate philosophical choice — the project's contrarian thesis is that AI is a partner *inside* a collaboration, not a separate entity you collaborate *with*. The name encodes that priority. See note `[10-04-2026] Renaming ai-collab-memory → collabmem` in `claude-collab` notes for the full reasoning.

**Changes since v1.7.2 (commit `c5caeb3`):**

- **README.md**: project renamed throughout (title, prose, install/upgrade prompts, GitHub URLs). Status line updated to v1.8.
- **install.md**: clone command, path examples, installation note template, and issues URL updated to use `collabmem`.
- **collab/methodology.md**: top-of-file label `<!-- ai-collab-memory -->` → `<!-- collabmem -->`, issues URL updated.
- **collab/.collab-memory-system**: bumped to `v1.8`.
- Historical entries in this `release-notes.md` (v1.7.2 and earlier) intentionally still reference "the ai-collab-memory repo" — those describe past state and are useful for installations still on older versions following the documented upgrade path.

**Upgrade from v1.7.2:**

The only *installed* file that changed is `collab/methodology.md` (the top-of-file label). `README.md` and `install.md` live in the source repo, not in your installation, so there is nothing to copy for those.

1. In your installation, copy `collab/methodology.md` from the new version into your collab directory (or just update the top-of-file comment from `<!-- ai-collab-memory -->` to `<!-- collabmem -->`).
2. Update your installation's `collab/.collab-memory-system` to `v1.8`.
3. No memory data migration required.

If you like you can rename `ai-collab-memory/` of your local, temporary, clone of the repo to `collabmem/`.

## v1.7.2

**Changes since v1.7.1 (commit `8b7cc7a`):**

- **collab/methodology.md**: New "shared-knowledge repo" definition in System Overview (Section 1) — for distributed collaboration scenarios where memory lives in a separate git repo across devices and/or users. Four new pull/push rules using this term:
  - readmem New Session: pull the shared-knowledge repo first (new step 1, "BEFORE continuing")
  - readmem How to read: pull the shared-knowledge repo before falling through to Tier 2 search — Tier 2 files on disk may have been updated remotely since session start
  - updatemem: new "Before writing updates" subsection — `git pull` before writing to keep memory current and minimise merge conflicts
  - Concurrency: replaces the previous "commit and push promptly" sentence with a symmetric "Pull before reading, push after writing" rule, explicitly tied to `readmem` and `updatemem`
- Follow-up (10-04-2026): all four pull/push rules clarified with "(ONLY the shared-knowledge repo — not the project code repo)". Trigger: AI pulled the project repo alongside the shared-knowledge repo at session start, conflating cwd with memory source-of-truth. Extra pulls aren't harmless — they may merge remote changes the user wasn't ready for. By definition the two always differ.
- Follow-up (10-04-2026): readmem "How to read" pull rule rephrased "BEFORE searching" → "BEFORE readmem" and moved to the top of the subsection. Trigger: fourth self-referential failure — AI skipped the New Session pull at session start because the rule was scoped to the search fall-through branch (only fires when Tier 1 looks insufficient). Rephrasing hooks the rule to the operation name itself for token-level attention coupling: every time "readmem" is in attention, "pull" fires alongside it. Promotes the rule from a sub-branch step to a precondition of the entire operation.
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
