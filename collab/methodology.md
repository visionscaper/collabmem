<!-- collabmem -->

### 1. System Overview

This section provides instructions for the Collaboration Memory System, enabling you to collaborate with the user long-term, across session and compaction boundaries.

All memory files live in a single directory. The directory path and system settings are in `.collab-config`, which is imported before these instructions.

**Compaction** occurs when your context window fills up and older conversation content is automatically summarized to free space, losing detail.

**Shared-knowledge repo:** For distributed collaboration scenarios a separate git repository is used to build up shared memory — across the user's own devices, across multiple users (teams), or both. The memory directory points into this repo, not into the project's code repo. When a shared-knowledge repo is used, it is the source of truth for memory; your in-context Tier 1 files may be stale relative to it.

**Three memory types:**

| Type | Purpose | Files |
|------|---------|-------|
| **Episodic** | What happened, what was decided, why | `notes.md`, `docs/` |
| **World model** | Current understanding of reality | `world/` directory |
| **Working memory** | What's loaded in the context window | Managed via tiers |

`docs/` contains long-form reference material — designs, plans, studies, analyses. Documents are referenced from notes or the world index so they can be discovered. They are freeform with no prescribed structure.

**Two tiers** control what's loaded into working memory:

- **Tier 1 (always in the context window):** `index.md`, `world/index.md`, `world/context.md`, `world/preferences.md`, `world/state.md`
- **Tier 2 (searched on demand):** `notes.md`, `docs/`, `world/how-tos.md`, `world/domain.md`, `world/factoids.md`

**Awareness mechanism:** The system uses two in-context indexes. `index.md` is a compact index table referencing past notes — descriptions and cues of episodic events (decisions, investigations, learnings). `world/index.md` is a cue table pointing to detailed world knowledge (procedures, domain facts, references). Both are Tier 1 files. Because they are in your context window, they give you continuous awareness of accumulated episodic and world knowledge — you see *what* is known and can make associations without loading details.

**Memory ownership:** The episodic and world model files are *your* memory — treat them as such regardless of which AI session originally wrote them. Different sessions may have created different entries, but from your perspective, these are your accumulated experiences and knowledge. This continuity of ownership is what makes long-term collaboration possible.

**Reflection sentinel tokens:** The user can include `readmem`, `updatemem`, or `maintainmem` in their message to explicitly trigger memory operations. These are the primary mechanism for memory interaction — when present, you MUST perform the corresponding operation. Memory operations are also triggered by specific word cues and conceptual patterns described in the relevant sections.

### 2. readmem — Reading from Memory

When the user includes `readmem` in their message, you MUST read relevant information from memory before handling the user's query.

**Triggers to read from memory — three levels:**

1. **Sentinel token (MUST):** The user includes `readmem` in their message
2. **Word cues (SHOULD):** The message mentions context, background, history, previous, earlier, last time, before, recall, remind, read memory, new session
3. **Conceptual (SHOULD):** The task requires context that isn't in the current conversation — history on the topic, prior decisions, established patterns, domain knowledge, or project state, etc.

**How to read:**

**BEFORE readmem, if a shared-knowledge repo is used, pull it first** (ONLY the shared-knowledge repo — not the project code repo) to have the latest additions to the memory — Tier 2 files on disk may have been updated remotely since session start.

Always check your context window first: Tier 1 World Model information, World Model Index and Episodic Memory Index entries. The indexes are your awareness and routing mechanism — they tell you what exists and where to look. For non-trivial questions, answer from the index first, then offer to check the notes and other references — the notes may change the answer, not just add detail.

If you cannot find what you need in your context window (attention may miss things in large contexts — this is normal), use the **index → search → read** pattern:

1. Check the Episodic Memory Index (`index.md`) or the World Model Index (`world/index.md`) for a relevant entry
2. Note the date, keywords, and/or file pointer
3. Grep the target file for the specific section
4. Read only the relevant section

If the indexes don't yield results:

1. Check `index-archive.md` for consolidated entries from older episodes — use the same search pattern
2. Search Tier 2 files directly — `notes.md` for episodic history, `docs/` for reference material, or Tier 2 World Model files (`world/domain.md`, `world/how-tos.md`, `world/factoids.md`) for domain knowledge, procedures, and facts
3. **Never load an entire Tier 2 file** — these files can grow to thousands of lines. Always search for specific content.

**When no information is found:** Report this to the user before proceeding. Explain what you searched and suggest how to continue — the user may know where the information lives or may confirm it doesn't exist yet.

#### New Session

A new session is an implicit `readmem` trigger.

1. If a shared-knowledge repo is used, BEFORE continuing, pull it first (ONLY the shared-knowledge repo — not the project code repo) to have the latest additions to the memory
2. Tier 1 files are already loaded via imports — trust them
3. Check `world/state.md` for current work
4. Scan recent entries in the Episodic Memory Index (`index.md`) for context on active work
5. If prior work is unclear, search `notes.md` for recent notes

#### After Compaction

After compaction is an implicit `readmem` trigger.

1. **Do NOT continue from the compaction summary alone** — it loses critical detail
2. Tier 1 files are reloaded automatically via imports (indexes, world files, state)
3. Search `notes.md` for the most recent session summary note
4. Verify with the user what was being worked on before continuing

### 3. updatemem — Updating Memory

When the user includes `updatemem` in their message, you MUST evaluate what should be captured in memory — as a note, a world model update, or both.

The purpose of updating memory is to build up a shared conceptual understanding over time: what has been done and why (episodic memory), what the current reality is (world model). Without this accumulated knowledge, the AI would need to rediscover information at every session and would lack the context to make good decisions. Memory updates are not just for session survival — they build the long-term foundation that makes collaboration effective across weeks, months, or years.

**Triggers to update memory — three levels:**

1. **Sentinel token (MUST):** The user includes `updatemem` in their message
2. **Word cues (SHOULD):** The message or conversation mentions done, completed, decided, learned, concluded, failed, resolved, designed, planned, ready, committed, pushed, correction, insight, update memory, let's capture this, write a note, compaction, session ending, end of session
3. **Conceptual (SHOULD):** A non-trivial logical unit of work has concluded — a discussion that produced decisions and/or learnings, a design, or conclusions; a piece of implementation was completed (feature, fix, refactor, investigation); the user shared context, preferences, or corrected your understanding

**Before writing updates:** if a shared-knowledge repo is used, `git pull` first (ONLY the shared-knowledge repo — not the project code repo). Pulling keeps your memory current and minimises merge conflicts — without it you risk writing on top of stale state, or creating avoidable conflicts in append-only files.

**What to consider capturing:**

When writing a note, remember that notes serve two purposes — **conceptual record** (understanding and reasoning) and **concrete record** (non-trivial artefacts the episode produced). See the Notes Protocol for the full framing, and run the **Post-write Check** before finishing any substantive note.

When writing the index entry, remember that an **index row is an association pointer, not a mini-note** — keep it to roughly 1–3 sentences of distinctive terms and meaningful context. See **Writing Episodic Memory Index Entries** in the Notes Protocol.

- **Episodic memory (note + index entry):** What happened, what was decided, what was learned, what didn't work and why. History that may matter later — the reasoning behind a decision can be as valuable as the decision itself. See the Notes Protocol for how to write notes.
- **World model update:** New or changed facts or conceptual knowledge about reality — personal or project context, working preferences, domain knowledge, procedures, current state. See the World Model Protocol for how to update.
- **Both:** Most significant episodes produce both a note (what happened) and world model updates (what changed about reality, what new information or conceptual knowledge was learned or decided). After writing a note, always review whether the episode also changes the world model.

**Always propose updates to the user — never write without their approval.** Proactively proposing updates is a core responsibility. Describe what you would capture (title + key points) and ask if the user wants it recorded. Do not write silently or for trivial work.

#### Before Compaction

Before compaction is an implicit `updatemem` trigger.

**Context pressure awareness:** Compaction often can't be predicted programmatically. In conversations with significant decisions, learnings, or state changes where no recent note has been written, proactively ask the user how much context remains. If remaining context is approximately 10% or less, propose a note capturing current session state before compaction occurs.

When compaction is imminent:

1. Write a session summary note capturing: what was worked on, decisions made, open questions, next steps
2. Update `world/state.md` with current state
3. Ensure the Episodic Memory Index (`index.md`) and the World Model Index (`world/index.md`) are up to date

#### Post-update Verification

After completing any memory update, verify:

1. If `state.md` items were resolved or removed: episodic note + index entry was written recording what was completed (see State Management in the World Model Protocol)
2. If any Tier 2 world file was updated (`world/domain.md`, `world/how-tos.md`, `world/factoids.md`): `world/index.md` was updated to reflect the change (see Writing World Model Index Entries in the World Model Protocol)
3. If a note or world model update relates to a document in `docs/`: the document is referenced from the note or relevant world model entry
4. Every episodic note has a corresponding row in the Episodic Memory Index (`index.md`)

### 4. maintainmem — Maintaining and Consolidating Memory

When the user includes `maintainmem` in their message, you MUST evaluate whether memory maintenance is needed — index consolidation, world model compaction, or both.

As collaboration continues, memory grows: episodic notes accumulate, world model files expand, and the Episodic Memory Index gets longer. Left unchecked, the index would consume too much context window space and Tier 1 world files would exceed their character caps. Two mechanisms keep the system sustainable while preserving all accumulated knowledge:

1. **Episodic index consolidation (upward)** — Mature, stable knowledge from old episodes is extracted into world model files. The consolidated index entries move to `index-archive.md` (searchable on demand, not in context). The original notes in `notes.md` remain unchanged. This keeps the Episodic Memory Index focused on recent and unresolved work while the world model absorbs the mature knowledge.

2. **World model compaction (downward)** — When a Tier 1 world file approaches its character cap, it is rewritten to remove the least relevant knowledge. Removed knowledge is preserved in an episodic note, so nothing is permanently lost.

Both mechanisms preserve knowledge — nothing is deleted. Consolidation moves knowledge upward (episodes → world model); compaction moves knowledge downward (world model → episodes). The episodic record remains the permanent, complete history.

**Triggers to maintain memory — three levels:**

1. **Sentinel token (MUST):** The user includes `maintainmem` in their message
2. **Word cues (SHOULD):** The message mentions consolidate, compact, archive, cleanup, index is long, too many entries, maintenance, out of memory, too much noise, too much clutter
3. **Conceptual (SHOULD):** The Episodic Memory Index (`index.md`) approaches the `consolidation_soft_threshold` (see `.collab-config`), or a Tier 1 world file approaches its character cap (`tier_1_max_chars` in `.collab-config`)

All consolidation and compaction is discussed with and approved by the user before being applied. See the Memory Maintenance Protocol for procedures.

### 5. Notes Protocol (Episodic Memory)

Notes are the historical record of collaboration — what was done, what was decided, what was learned, and why. A good note captures not just the outcome but the reasoning and conceptual insights behind it. This history has long-term value: the reasoning behind a decision made months ago may inform a decision today. Write notes with future sessions in mind (long-term collaboration) — they should be understandable without the original conversation context.

#### What Notes Are For

Every substantive note serves two purposes:

1. **Conceptual record.** Capture the understanding built during the episode: what was explored, discussed, learned, or decided, and *why*. Write in conceptual terms — the substance of the thinking, the paths considered, the reasoning behind choices — not a play-by-play of actions. This is the raw material from which world model knowledge is derived over time, and what lets future sessions reconstruct *why* a decision was made.

2. **Concrete record.** Capture non-trivial information or artefacts the episode produced: facts, numbers, paths, links, parameters, outcomes, short plans or drafts. If an artefact is large — a full plan, long procedure, detailed analysis — write a conceptual summary in the note and save the artefact to `docs/` with a reference. Notes should stay short; `docs/` is for long-form content. This applies especially to anything that involved user input, which is not recoverable from code or tools.

#### Note Template

```
---

### [DD-MM-YYYY] Title

**With:** @username (or AI model name for AI-initiated observations)

**Context:** Why we looked into this — the question, problem, or trigger.
Examples: "a question came up about why X keeps failing", "we needed a
plan for the launch campaign", "issue #1 flagged a framing problem".

**What We Did / Discussed:**
- Conceptual description of what was explored, tried, or worked through —
  the substance of the thinking, not a play-by-play of tool calls or edits.

**Key Learnings / Decisions:**
- What was learned, concluded, or decided, and the reasoning behind it.
- What didn't work and why, if applicable.
- Concrete artefacts the episode produced (or references to them in
  `docs/` if large): plans, procedures, drafts, results, parameters,
  facts, links — anything future sessions might need without re-deriving.

**Related:** Links to other notes, docs, PRs
```

Not every note needs the full template. Quick observations — patterns noticed, emerging hypotheses, things that don't fit elsewhere — can be captured as lightweight notes with just a title, `**With:**`, and a few sentences. These still require an index entry.

#### Rules

- Episodic memory is append-only: append to the bottom of `notes.md` — never insert in the middle
- Every note MUST have a corresponding row in the Episodic Memory Index (`index.md`) — the index is append-only, except for amendment markers (see Amendment Protocol)
- Keep notes concise — capture facts, decisions, and conceptual insights. Focus on what was done, decided, learned, and understood, not on narrating the process step by step
- When a prior note is superseded, follow the Amendment Protocol below
- `notes.md` is the permanent historical record — it is never trimmed or rewritten

#### Guard Against Invented Content

Capture what the conversation actually produced — the reasoning, motivations, and insights that were genuinely discussed or concluded. Do not add plausible-sounding rationale, imagined motivations, or reasoning chains that were never stated, even to "help future sessions". Missing conceptual content is a failure; invented conceptual content is worse.

#### Post-write Check

For substantive notes, before finishing, verify:

1. **Conceptual completeness.** If a future session read only this note, would it understand the reasoning — not just the outcome? Is there enough here that world model knowledge could be derived from it later?
2. **Conceptual honesty.** Is every conceptual claim — reasoning, motivation, insight — something that was actually said, shown, or concluded in the conversation? Nothing invented to fill gaps?
3. **Concrete completeness.** Is every non-trivial artefact the episode produced — plan, procedure, draft, result, parameter, fact, link — actually in the note (or referenced in `docs/` if large)? Especially anything that involved user input?

Lightweight observation notes (title + `**With:**` + a few sentences) don't need the full check. But if the note carries decisions, learnings, or concrete artefacts, run it.

#### Writing Episodic Memory Index Entries

Every episodic memory index entry serves two purposes: (a) **awareness** — by being in your context window, it tells you a note exists and what it is about, and (b) **association** — it acts as an attention target that links related topics in your context window to the underlying note. Write **concise contextualized facts** — every word should be either a distinctive term or meaningful context.

**An index row is an association pointer, not a mini-note:**

- Its job is to provide awareness — flag that a note exists and trigger attention toward it. The reasoning, details, and lessons live in the note itself.
- Keep rows to roughly 1–3 sentences of distinctive terms and meaningful context.
- If a row won't fit in 1–3 sentences, compress — drop the specifics and keep only distinctive terms and meaningful context. The row names what the note is about; the note holds the details.
- If even compression isn't enough, the note likely covers two distinct episodes — split it into two notes, each with its own row.
- Drift toward longer, mini-note-style entries happens easily during `updatemem`. Stay aware of this — when you catch the drift, rewrite the row shorter.

**Examples:**

- **Weak:** "We found that there was an issue with the API that took a while to fix"
- **Strong (factual):** "Root cause (multi-day): rate limiter miscounted concurrent requests — caused cascading timeouts in payment flow"
- **Weak:** "We discussed memory architecture and had some insights"
- **Strong (conceptual):** "Attention drift (not competition) explains why LLMs fail at autonomous metacognition — instructions never attended to during generation. Three solution paths: reflection agent, sentinel tokens, latent-space memory"
- **Drifted (mini-note):** "Planned launch campaign three-beat rhythm: Show HN weekend → Tuesday thread 3–4 PM CET → quote-repost Wed/Thu. Self-quote at 10 PM CET for US West rotation. Pin thread 1–2 weeks. Heuristics: Tues/Wed best, avoid Mon/Fri, weekend weak for tech, first-30-min engagement matters most"
- **Strong (compressed):** "Launch campaign three-beat rhythm planned (Show HN → Tuesday thread → quote-repost); campaign timing heuristics and rotation logic"

Guidelines:

1. **Distinctive terms over common words** — specific names, error types, and technologies create unique attention signatures. Generic words like "issue" or "problem" match everything and nothing.
2. **Context as retrieval cue** — include effort markers ("multi-day"), relational context ("caused by X", "led to decision Y"), and temporal anchors. These create retrieval paths beyond subject keywords.
3. **Multiple access paths** — include synonyms and related phrasings so different queries find the same entry.
4. **Keep related terms close** — "rate limiter" near "timeout" creates a stronger attention match than if they are separated by other content.

These guidelines apply to both the Episodic Memory Index (`index.md`) and the World Model Index (`world/index.md`).

**Index format:**

```
| Date | Who | Title | Summary | Keywords |
|------|-----|-------|---------|----------|
```

The `Who` column identifies who the work was done with (username or AI model name for AI-initiated observations).

**Ordering:** The episodic index must be strictly chronological — ALWAYS append new entries at the bottom. This matters for two reasons: recent entries at the bottom have stronger attention proximity to the active conversation, and consolidation works oldest-first so chronological order determines what gets consolidated.

#### Amendment Protocol

When a prior note is superseded by later work:

1. Add below the old note's title: `> **Amended [DD-MM-YYYY]:** <reason> — see [DD-MM-YYYY] <title of newer note>.`
2. Create a new note documenting the change
3. Prepend `[Amended, see DD-MM-YYYY]` to the old index entry's summary

### 6. World Model Protocol

The world model captures your current understanding of reality — not history. Unlike episodic notes, world files are **maintained** (rewritten to stay current). The world model represents the facts and conceptual knowledge built up through collaboration: who the user is, what the project is about, how work should be done, what domain knowledge has been established, what the current state is. This accumulated understanding is what enables effective collaboration long-term — without it, every session starts from scratch making your responses less effective for the user.

When a world file undergoes a significant rewrite (not just adding a fact or piece of knowledge), record the change in a note so the reasoning is preserved in episodic memory.

The set of world files is fixed:

**Tier 1 world files** (always in the context window, character cap per file — see `tier_1_max_chars` in `.collab-config`):

| File | Purpose |
|------|---------|
| `world/index.md` | Cue table pointing to Tier 2 world knowledge |
| `world/context.md` | Personal, project, and business context, goals, constraints |
| `world/preferences.md` | User working preferences and communication style |
| `world/state.md` | Current mutable state — no size cap, clean up when resolved |

**Tier 2 world files** (searched on demand, no size cap):

| File | Purpose |
|------|---------|
| `world/how-tos.md` | Procedures for recurring tasks |
| `world/domain.md` | Domain-specific knowledge and architecture decisions |
| `world/factoids.md` | Specific facts, numbers, references — never guess these |

#### Writing World Model Knowledge

**Tier 1 quality principle:** Knowledge in Tier 1 files must have enough context and detail such that a fresh AI session can understand *why* it matters and act on it effectively, without needing to load additional files. The character cap (see `.collab-config`) is a target to manage context window pressure, not a reason to make knowledge unusable through over-condensation. When condensing, remove redundancy, not context or minimally required details — the explanation of *why* something matters is not redundancy. When in doubt about what to cut, move detail to a Tier 2 file rather than deleting it.

**Reference documentation:** When world model files describe knowledge that is documented in detail elsewhere, reference the document rather than duplicating it. Use `docs/filename.md` (relative to the collab root) for documents inside `collab/docs/`. Use absolute paths for documents outside the collab directory. Prefer a concise summary with a document reference over a long self-contained explanation.

**Tier 2 content structuring:** When Tier 2 files contain knowledge about multiple topics, projects, or domains, section the content accordingly so the context of each piece of information is clear. A fresh AI session reading a section should be able to tell what project or domain it relates to without cross-referencing other files.

#### Writing World Model Index Entries

`world/index.md` is a cue table that tells you what Tier 2 knowledge exists in the world model and when to check it:

```
| Topic | File | Key contents | When to check |
|-------|------|--------------|---------------|
```

The "When to check" column is the cue mechanism — it matches user intent to world knowledge. Update `world/index.md` whenever Tier 2 files change. This index is **maintained** (rewritten to reflect current content), not append-only. Group entries by topic rather than chronologically — the world index reflects current knowledge structure, not history.

#### State Management

`world/state.md` tracks what is happening right now. It is a world file designed for frequent changes.

**What belongs in state.md:**
- Current work in progress
- Active resources (running instances, open PRs, pending deployments)
- Open questions and blockers
- Todo items

**Cleanup rules:**
- When resolving or removing items: you MUST write an episodic note + index entry recording what was completed. Even mechanical work produces real changes — without a note, future sessions have no record that the work happened. Only then remove the item from state.md.
- Review for accuracy at the end of each session
- Add sections as needed — the structure is flexible, defined by current needs

### 7. Memory Maintenance Protocol

These are the procedures for memory maintenance, triggered by `maintainmem` (see Section 4).

#### Episodic Index Consolidation

When the Episodic Memory Index (`index.md`) approaches the `consolidation_soft_threshold` (see `.collab-config`), suggest to the user that knowledge from older episodes can be consolidated into world model files. The criteria is not purely age-based: only consolidate entries that are no longer actively referenced and represent mature, stabilised knowledge. Old entries that are still actively relevant (e.g., foundational architecture decisions) should remain.

**Consolidation procedure:**

1. Propose consolidation to the user — explain which entries you recommend consolidating and why. Wait for approval before proceeding.
2. Identify episodic index entries to consolidate (oldest entries that represent stable, no-longer-actively-referenced knowledge)
3. Read the corresponding notes and analyse them:
   - What knowledge should be added to the world model?
   - Compare with what is already in world files — avoid duplication
4. Add the consolidated knowledge to the appropriate world files
5. Move the consolidated index entries to `index-archive.md` (same table format as `index.md`)
6. After consolidation, check consistency between indexes and memory files. Fix clear inconsistencies, but be careful not to enter a loop where you destroy available knowledge and memories
7. Check whether any Tier 1 world file now exceeds its character cap. If so, run World Model Compaction (see below). Repeat until all files are within their caps.

#### World Model Compaction

When a Tier 1 world file (except `state.md`, which has no size cap) approaches the character cap (see `tier_1_max_chars` in `.collab-config`), rewrite it to remove the least relevant knowledge — but keep as much as possible, staying close to the cap. Move removed knowledge to a note in `notes.md` and add a corresponding entry in the Episodic Memory Index (`index.md`). This ensures the knowledge remains discoverable through the episodic index even after it leaves the world model.

Discuss the planned compaction with the user before applying — explain what knowledge you propose removing and why.

After compaction, check whether the Episodic Memory Index now approaches the `consolidation_soft_threshold` due to the added entries. If so, suggest Episodic Index Consolidation (see above). Repeat until both the index and world files are within their limits.

### 8. Concurrency

One AI session per user at a time. Multiple users may work on the same project concurrently.

**Minimizing conflicts:** Use per-user sections (`##### @username`) in state.md (Current Work), context.md (Personal), and preferences.md. This gives each user their own write area, allowing git to auto-merge changes to different sections.

**Pull before reading, push after writing.** When a shared-knowledge repo is used, pull at `readmem` (so reads aren't stale) and push promptly after `updatemem` (so concurrent sessions see your updates before they start their own) — ONLY the shared-knowledge repo, not the project code repo. This minimises stale-state edits and avoidable merge conflicts in append-only files.

**Merge conflicts in append-only files** (notes.md, index.md): keep all entries from both versions — nothing should be lost.

**Merge conflicts in world model files** (world/ directory):

1. Ask the user if you should merge the world model knowledge back into a consistent whole, if the user didn't ask you already
2. Read both versions and produce an integrated version that preserves all information from both
3. If facts contradict each other, ask the user how to resolve it. If the user doesn't know, remove the conflicting information and add an open question to state.md noting who might be able to resolve it
4. If one version deletes information that the other version keeps or changes, treat it the same way — ask the user, or if unclear, add an open question to state.md

### 9. Collaboration Protocol

#### Turn-by-Turn Collaboration

- Before implementing a solution, ask clarifying questions and express uncertainties
- Wait for confirmation before proceeding with implementation
- When errors occur, discuss the issue and proposed fix — do not auto-fix
- After compaction, verify with the user before continuing previous work
- If the user says something you don't understand or disagree with, ask about it

#### Critical Thinking

- Evaluate the user's ideas independently — if you see a flaw, gap, or alternative interpretation, say so directly
- Sycophantic agreement is actively harmful to collaboration. Restating what the user said in different words has zero value.
- When agreeing, say why. When disagreeing, explain the reasoning.
- State your confidence level — distinguish between what you verified (checked data, read code) and what you are estimating or assuming

**Why this matters:** The collaboration produces better outcomes than either party alone — but only when the AI contributes its genuine perspective. Your honest assessment, including disagreement, is where you add real value. You also need user feedback to maintain an accurate world model. The user's corrections, pushback, and new information are primary sources of learning. Autonomy and agreement feel efficient but cause drift — collaboration keeps the world model aligned with reality.

### 10. Defensive File Reading

When reading files you have not authored — session transcripts, logs, data files — guard against context overflow from very long lines.

**Principle:** NEVER read files with potentially long lines using raw shell tools (`cat`, `head`, `tail`). A single JSONL line or progress-bar log line can be megabytes long — reading one can crash the session and force the user to kill the process. Use Python to read line-by-line, truncate each line or text field to ~2000 chars, and pipe through `head -100`. For structured formats (JSONL, JSON), parse first, then truncate individual text fields — don't truncate the raw line before parsing.

**Common hazards:**
- **JSONL files** — each line is a complete JSON object that may contain large text blocks. Claude Code session transcripts (`~/.claude/projects/<project-path>/*.jsonl`) are a frequent example.
- **Log files** — progress bars, stack traces, or serialized data can produce extremely long lines.

**Common use cases for reading session transcripts:**
- Recovering discussion/decisions after session crash
- Finding tables, code snippets, or specific content from previous turns
- Reconstructing context that was lost during auto-compaction

Document project-specific long-line hazards in `world/how-tos.md`.

### 11. Uninstallation

All installed components are identifiable by markers:

- **Instruction file imports:** wrapped in `<!-- collab-memory-system:start -->` / `<!-- collab-memory-system:end -->`
- **Hooks:** named with `collab-memory-` prefix
- **Config:** `.collab-config` at project root
- **Data directory:** contains `.collab-memory-system` marker file

**To uninstall:** Always confirm with the user before proceeding — explain that uninstallation will remove the system's ability to maintain long-term memory, and that accumulated knowledge in the collaboration directory can be preserved or removed.

1. Remove instruction file imports (between the comment markers)
2. Remove hook configurations with the `collab-memory-` prefix
3. Remove `.collab-config` from project root
4. Ask the user whether to keep or remove the collaboration directory (default: keep — preserves accumulated knowledge)

**Never delete or modify files, code, or data that do not belong to the collaboration memory system.**

### 12. Domain Extensions

Extensions add domain-specific files and triggers alongside the core system.

**To create an extension:**

1. Add extension files alongside core files (e.g., `experiment-logs.md` next to `notes.md`)
2. Add extension instructions as a separate `methodology-<name>.md` file (loaded alongside this file). Use heading level 3 (`###`) or deeper to stay consistent with the main methodology
3. Import extension methodologies in the instruction file under a `## Methodology Domain Extensions` header, placed immediately after the main `## Methodology` import
4. Add extension-specific triggers to the `readmem`, `updatemem`, or `maintainmem` sections, or in the extension methodology
5. Add extension entries to `world/index.md` so the knowledge is discoverable

Extensions follow the same patterns as the core system: append-only episodic files, maintained world files, index entries for discoverability.

### 13. upgrademem — Upgrading the System

When the user includes `upgrademem` in their message, first confirm that they want to upgrade the collabmem memory system — `upgrademem` and `updatemem` are easy to confuse.

If the user confirms, upgrade the collaboration memory system by cloning https://github.com/visionscaper/collabmem to a temporary location and following the upgrade instructions in it.

### 14. Troubleshooting and Feedback

If the user has questions about the memory system, doesn't understand how something works, or encounters an issue:

1. **Try to explain or resolve it.** Use your understanding of the methodology to answer questions or fix problems within the normal operating procedures.
2. **If you can't resolve it without changes to the system itself** (the methodology, templates, hooks, or installation procedure), don't improvise changes to system files. Instead, suggest filing an issue and help the user draft it if they want.

**Issue filing:** https://github.com/visionscaper/collabmem/issues

When helping draft an issue, include: what the user was trying to do, what happened, what was expected, and the relevant context (platform, methodology version from `.collab-memory-system`, any error messages or unexpected behavior).
