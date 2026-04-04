# Release Notes

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
