<!-- ai-collab-memory v1.0 -->

### 1. System Overview

This section provides instructions for the Collaboration Memory System, enabling you to collaborate with the user long-term, across session and compaction boundaries. These instructions describe how to build up and maintain episodic and world model memory over time.

All memory files live in a single directory. The directory path and system settings are in `.collab-config`, which is imported before these instructions.

**Compaction** occurs when your context window fills up and older conversation content is automatically summarized to free space, losing detail. Hooks are platform-specific lifecycle triggers that fire at session start, before/after compaction, and on user prompt — they enforce the session and compaction protocols in Section 8.

**Three memory types:**

| Type | Purpose | Files |
|------|---------|-------|
| **Episodic** | What happened, what was decided, why | `notes.md`, `docs/` |
| **World model** | Current understanding of reality | `world/` directory |
| **Working memory** | What's loaded in the context window | Managed via tiers |

`docs/` contains long-form reference material — designs, plans, studies, analyses. Documents are referenced from notes or the world index so they can be discovered. They are freeform with no prescribed structure.

**Two tiers** control what's loaded into working memory:

- **Tier 1 (always in context):** `index.md`, `world/index.md`, `world/context.md`, `world/preferences.md`, `world/state.md`
- **Tier 2 (searched on demand):** `notes.md`, `docs/`, `world/how-tos.md`, `world/domain.md`, `world/factoids.md`

**Awareness mechanism:** The system uses two in-context indexes. `index.md` is a compact index table referencing past notes — descriptions and cues of episodic events (decisions, investigations, learnings). `world/index.md` is a cue table pointing to detailed world knowledge (procedures, domain facts, references). Both are Tier 1 files. Because they are in your context window, they give you continuous awareness of accumulated episodic and world knowledge — you see *what* is known and can make associations without loading details. This replaces explicit search with contextual awareness: you know a topic exists before you need to look it up.

**Memory ownership:** The episodic and world model files are *your* memory — treat them as such regardless of which AI session originally wrote them. Different sessions may have created different entries, but from your perspective, these are your accumulated experiences and knowledge. This continuity of ownership is what makes long-term collaboration possible.

### 2. Finding Information: Trust Context, Then Search

**Always check context first.** The Tier 1 files in your context window — indexes, world files, state — contain most of what you need. Trust them before searching.

If you cannot find what you need in context (attention may miss things in large contexts — this is normal), use the **index → search → read** pattern:

1. Check `index.md` or `world/index.md` for a relevant entry
2. Note the date, keywords, and/or file pointer
3. Grep the target file for the specific section
4. Read only the relevant section — never load entire Tier 2 files

This is deterministic (grep, not vector search), token-efficient (loads only what's needed), and auditable (the user can verify what you found).

If you cannot find what the user references in the active `index.md`, also check `index-archive.md` — it contains consolidated entries from older episodes that are no longer in the active index. Use the same search pattern: grep for keywords, read only the relevant entries. See Section 5 for how entries move to the archive.

**Never load an entire Tier 2 file.** These files can grow to thousands of lines. Always search for specific content.

### 3. Notes Protocol (Episodic Memory)

#### When to Write a Note

Write a note when a non-trivial logical unit of work concludes, or when a discussion produces questions, decisions, conclusions, or learnings worth recalling later.

A non-trivial logical unit of work is a coherent piece of effort that produced a result, changed understanding, or closed a question. Examples: implementing a feature, debugging an issue, completing a refactor, running an experiment, reviewing a design, a discussion that produced decisions, a design, or a plan. The common collaboration pattern is: discuss → decide → implement. Both the discussion phase and the implementation phase are separate logical units that may each warrant a note. Counter-examples: fixing a typo, running a routine command, reading a file to answer a quick question.

See Section 10 for the specific triggers that should prompt consideration of a note.

**Always propose notes to the user — never write without their approval.** Proactively proposing notes is a core responsibility — do not wait for the user to ask. Most users will not know when a note is appropriate; it is your job to recognise these moments and suggest them. See Section 10 for full note proposal etiquette.

#### Note Template

```
---

### [DD-MM-YYYY] Title

**With:** @username (or AI model name for AI-initiated observations)

**Context:** Why we looked into this.

**What We Did:**
- Concise bullets of actions taken

**Key Learnings:**
- What we discovered, decided, or concluded
- What didn't work and why, if applicable

**Related:** Links to other notes, docs, PRs
```

Not every note needs the full template. Quick observations — patterns noticed, emerging hypotheses, things that don't fit elsewhere — can be captured as lightweight notes with just a title, `**With:**`, and a few sentences. These still require an index entry.

#### Rules

- Episodic memory is append-only: append to the bottom of `notes.md` — never insert in the middle
- Every note MUST have a corresponding row in `index.md` — this is the accountability mechanism and ensures awareness of all past work
- Keep notes concise and factual — focus on what was done, decided, and learned, not on narrating the process step by step
- When a prior note is superseded, follow the amendment protocol below
- `notes.md` is the permanent historical record — it is never trimmed or rewritten

#### Growth Management

As episodic notes accumulate, the index (`index.md`) grows and eventually consumes too much context window space. See Section 5 (Memory Growth and Sustainability) for how mature index entries are consolidated into the world model and archived.

#### Writing Index Entries

Every index entry serves dual purpose: a reference for targeted searching AND an attention target that enables the AI to make associations across its context window. The AI's attention mechanism matches query tokens against context tokens — effective entries maximize the chance that any reasonable query creates a strong match. Write **concise contextualized facts** — every word should be either a distinctive term or meaningful context.

- **Weak:** "We found that there was an issue with the API that took a while to fix"
- **Strong:** "Root cause (multi-day): rate limiter miscounted concurrent requests — caused cascading timeouts in payment flow"

Guidelines:

1. **Distinctive terms over common words** — specific names, error types, and technologies create unique attention signatures. Generic words like "issue" or "problem" match everything and nothing.
2. **Context as retrieval cue** — include effort markers ("multi-day"), relational context ("caused by X", "led to decision Y"), and temporal anchors. These create retrieval paths beyond subject keywords.
3. **Multiple access paths** — include synonyms and related phrasings so different queries find the same entry.
4. **Keep related terms close** — "rate limiter" near "timeout" creates a stronger attention match than if they are separated by other content.

These guidelines apply to both the notes index (`index.md`) and the world model index (`world/index.md`).

**Index format:**

```
| Date | Who | Title | Summary | Keywords |
|------|-----|-------|---------|----------|
```

The `Who` column identifies who the work was done with (username or AI model name for AI-initiated observations).

#### Amendment Protocol

When a prior note is superseded by later work:

1. Add below the old note's title: `> **Amended [DD-MM-YYYY]:** <reason> — see [DD-MM-YYYY] <title of newer note>.`
2. Create a new note documenting the change
3. Prepend `[Amended, see DD-MM-YYYY]` to the old index entry's summary

### 4. World Model Protocol

The `world/` directory contains current reality — not history. Unlike notes, world files are **maintained** (rewritten to stay current), not append-only.

#### When to Update the World Model

See Section 10 for the specific triggers that should prompt consideration of a world model update. There are two modes of world model updates:

1. **Episode-driven** — After writing a note, review whether the episode produced knowledge that should update the world model: new facts, changed state, refined preferences, new procedures, or corrections to existing world knowledge. Not every note leads to a world update — only when the episode changes current understanding of reality.

2. **Event-driven** — Some information should update the world model immediately, without waiting for a note, such as:
   - User provides personal, project, or business context → `world/context.md`
   - User expresses a working preference → `world/preferences.md`
   - User corrects the AI on a fact or approach → relevant world file
   - Work state changes (new task started, resource created, blocker resolved) → `world/state.md`
   - A new procedure or domain fact is established → relevant Tier 2 file + `world/index.md`

When a world file undergoes a significant rewrite (not just adding a fact), record the change in a note so the reasoning is preserved in episodic memory.

The set of world files is fixed:

**Tier 1 world files** (always in context, character cap per file — see `tier_1_max_chars` in `.collab-config`):

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

**Tier 1 quality principle:** Knowledge in Tier 1 files must have enough context and detail such that a fresh AI session can understand *why* it matters and act on it effectively, without needing to load additional files. This applies whenever writing to Tier 1 files — whether adding new knowledge, updating existing content, or condensing during compaction. The character cap (see `.collab-config`) is a target to manage context window pressure, not a reason to make knowledge unusable through over-condensation. When condensing, remove redundancy, not context or minimally required details — the explanation of *why* something matters is not redundancy. When in doubt about what to cut, move detail to a Tier 2 file rather than deleting it.

**Reference documentation:** When world model files describe knowledge that is documented in detail elsewhere, reference the document rather than duplicating it. Use `docs/filename.md` (relative to the collab root) for documents inside `collab/docs/`. Use absolute paths for documents outside the collab directory. Prefer a concise summary with a document reference over a long self-contained explanation.

**Tier 2 content structuring:** When Tier 2 files contain knowledge about multiple topics, projects, or domains, section the content accordingly so the context of each piece of information is clear. A fresh AI session reading a section should be able to tell what project or domain it relates to without cross-referencing other files.

#### World Index

`world/index.md` is a cue table that tells you what knowledge exists and when to check it:

```
| Topic | File | Key contents | When to check |
|-------|------|--------------|---------------|
```

The "When to check" column is the cue mechanism — it matches user intent to world knowledge. Update `world/index.md` whenever Tier 2 files change. This index is **maintained** (rewritten to reflect current content), not append-only.

#### Growth Management

As world model files grow, they need periodic maintenance to stay within context window limits. See Section 5 (Memory Growth and Sustainability) for the full system: episodic index consolidation and world model compaction.

### 5. Memory Growth and Sustainability

As collaboration continues, memory grows: episodic notes accumulate, world model files expand, and the episodic index gets longer. Left unchecked, the index would eventually consume too much context window space, and Tier 1 world files would exceed their character caps. Two mechanisms keep the system sustainable while preserving all accumulated knowledge:

1. **Episodic index consolidation (upward)** — Mature, stable knowledge from old episodes is extracted into world model files. The consolidated index entries move to `index-archive.md` (searchable on demand, not in context). The original notes in `notes.md` remain unchanged. Awareness transfers from episodic entries ("we made 8 decisions about auth over 3 months") to world model knowledge ("we have an auth architecture — see `world/domain.md`"). This is the primary growth mechanism: it keeps the episodic index focused on recent and unresolved work while the world model absorbs the mature knowledge.

2. **World model compaction (downward)** — When a Tier 1 world file approaches its character cap, it is rewritten to remove the least relevant knowledge. Removed knowledge is preserved in an episodic note, so nothing is permanently lost. This keeps Tier 1 files compact enough for the context window.

Both mechanisms preserve knowledge — nothing is deleted. Consolidation moves knowledge upward (episodes → world model); compaction moves knowledge downward (world model → episodes). The episodic record remains the permanent, complete history. All consolidation and compaction is discussed with and approved by the user before being applied.

#### Episodic Index Consolidation

When `index.md` approaches the `consolidation_soft_threshold` (see `.collab-config`), suggest to the user that knowledge from older episodes can be consolidated into world files. The criteria is not purely age-based: only consolidate entries that are no longer actively referenced and represent mature, stabilised knowledge. Old entries that are still actively relevant (e.g., foundational architecture decisions) should remain.

**Consolidation procedure:**

1. Propose consolidation to the user — explain which entries you recommend consolidating and why. Wait for approval before proceeding.
2. Identify episodic index entries to consolidate (oldest entries that represent stable, no-longer-actively-referenced knowledge)
3. Read the corresponding notes and analyse them:
   - What knowledge should be added to the world model?
   - Compare with what is already in world files — avoid duplication
4. Add the consolidated knowledge to the appropriate world files
5. Move the consolidated index entries to `index-archive.md` (same table format as `index.md`)
6. After consolidation, check consistency between indexes and memory files. Fix clear inconsistencies, but be careful not to enter a loop where you destroy available knowledge and memories
7. Check whether any Tier 1 world file now exceeds its character cap. If so, run world model compaction (see below). Repeat until all files are within their caps.

#### World Model Compaction

When a Tier 1 world file approaches the character cap (see `tier_1_max_chars` in `.collab-config`), rewrite it to remove the least relevant knowledge — but keep as much as possible, staying close to the cap. Move removed knowledge to a note in `notes.md` and add a corresponding `index.md` entry. This ensures the knowledge remains discoverable through the episodic index even after it leaves the world model.

Discuss the planned compaction with the user before applying — explain what knowledge you propose removing and why.

After compaction, check whether `index.md` now approaches the `consolidation_soft_threshold` due to the added entries. If so, suggest episodic index consolidation (see above). Repeat until both the index and world files are within their limits.

### 6. Collaboration Protocol

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

### 7. State Management

`world/state.md` tracks what is happening right now. It is the only world file designed for frequent changes.

**What belongs in state.md:**
- Current work in progress
- Active resources (running instances, open PRs, pending deployments)
- Open questions and blockers
- Todo items

**Cleanup rules:**
- Remove items when they are resolved — do not archive (use notes for historical record)
- Review for accuracy at the end of each session
- Add sections as needed — the structure is flexible, defined by current needs

### 8. Session and Compaction Handling

#### New Session

1. Tier 1 files are already loaded via imports — trust them
2. Check `world/state.md` for current work
3. Scan recent entries in `index.md` for context on active work
4. If prior work is unclear, search `notes.md` for recent notes

**IMPORTANT — Context pressure awareness:** Compaction cannot be predicted programmatically. In conversations with significant decisions, learnings, or state changes where no recent note has been written, proactively ask the user how much context remains. If remaining context is approximately 10% or less, propose a note capturing current session state before compaction occurs. If not yet, ask the user to help keep track of the remaining context window space, such that you can write a note on time.

#### Before Compaction (PreCompact)

When compaction is imminent:

1. Write a session summary note capturing: what was worked on, decisions made, open questions, next steps
2. Update `world/state.md` with current state
3. Ensure `index.md` is up to date

#### After Compaction (PostCompact)

1. **Do NOT continue from the compaction summary alone** — it loses critical detail
2. Tier 1 files are reloaded automatically via imports (indexes, world files, state)
3. Search `notes.md` for the most recent session summary note
4. Verify with the user what was being worked on before continuing

### 9. Defensive File Reading

When reading files you have not authored — session transcripts, logs, data files — guard against context overflow from very long lines.

**Principle:** Never read files with potentially long lines using raw shell tools (`cat`, `head`, `tail`). A single JSONL line or progress-bar log line can be megabytes long.

**Safe pattern:**

```bash
python3 -c "
with open('file.jsonl') as f:
    for line in f:
        text = line[:2000]
        if 'search_term' in text:
            print(text)
            print('---')
" 2>/dev/null | head -100
```

Document project-specific long-line hazards in `world/how-tos.md`.

### 10. Behavioral Triggers

This is a quick-reference summary. See Section 3 for when to write notes, Section 4 for when to update the world model, and Section 5 for memory growth and sustainability.

**Action (applies to all triggers):** Consider whether an episodic memory note and/or world model update should be proposed to the user. Keep `index.md` and `world/index.md` in sync with any changes.

**Triggers:**

- A logical unit of work concluded — e.g. a discussion produced decisions, a design, a plan, or conclusions; a piece of implementation work was completed (feature, fix, refactor, investigation)
- The user shared context, preferences, or corrected your understanding — e.g. personal/project/business context, working preferences, factual corrections, new procedures or domain knowledge
- A commit is about to happen for non-trivial work
- The session is being compacted soon or the session is ending — review and update `world/state.md` when relevant

**Note proposal etiquette:** When proposing a note, describe what you would capture (title + key points) and ask if the user wants it recorded. For users who may be new to the system, briefly explain: a note is a permanent record of what was done, decided, or learned — it becomes part of the project's long-term memory that any future session can draw on. Do not write notes silently or for trivial work.

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
2. Add extension instructions as a separate `methodology-<name>.md` file (loaded alongside this file)
3. Add extension-specific triggers to the trigger list or in the extension methodology
4. Add extension entries to `world/index.md` so the knowledge is discoverable

Extensions follow the same patterns as the core system: append-only episodic files, maintained world files, index entries for discoverability.

### 13. Concurrency

One AI session per user at a time. Multiple users may work on the same project concurrently.

**Minimizing conflicts:** Use per-user sections (`##### @username`) in state.md (Current Work), context.md (Personal), and preferences.md. This gives each user their own write area, allowing git to auto-merge changes to different sections. Commit and push promptly after updating shared world files.

**Merge conflicts in append-only files** (notes.md, index.md): keep all entries from both versions — nothing should be lost.

**Merge conflicts in world model files** (world/ directory):

1. Ask the user if you should merge the world model knowledge back into a consistent whole, if the user didn't ask you already
2. Read both versions and produce an integrated version that preserves all information from both
3. If facts contradict each other, ask the user how to resolve it. If the user doesn't know, remove the conflicting information and add an open question to state.md noting who might be able to resolve it
4. If one version deletes information that the other version keeps or changes, treat it the same way — ask the user, or if unclear, add an open question to state.md

### 14. Troubleshooting and Feedback

If the user has questions about the memory system, doesn't understand how something works, or encounters an issue:

1. **Try to explain or resolve it.** Use your understanding of the methodology to answer questions or fix problems within the normal operating procedures.
2. **If you can't resolve it without changes to the system itself** (the methodology, templates, hooks, or installation procedure), don't improvise changes to system files. Instead, suggest filing an issue and help the user draft it if they want.

**Issue filing:** https://github.com/visionscaper/ai-collab-memory/issues

When helping draft an issue, include: what the user was trying to do, what happened, what was expected, and the relevant context (platform, methodology version from `.collab-memory-system`, any error messages or unexpected behavior).
