# Collaboration Memory System — Methodology

<!-- ai-collab-memory v1.0 -->

## 1. System Overview

This section provides instructions for the Collaboration Memory System, enabling you to collaborate with the user long-term, across session and compaction boundaries. These instructions describe how to build up and maintain episodic and world model memory over time.

All memory files live in a single directory. The directory path and system settings are in `.collab-config`, which is imported before these instructions.

**Compaction** occurs when your context window fills up and older conversation content is automatically summarized to free space, losing detail. Hooks are platform-specific lifecycle triggers that fire at session start, before/after compaction, and on user prompt — they enforce the session and compaction protocols in Section 7.

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

## 2. Finding Information: Trust Context, Then Search

**Always check context first.** The Tier 1 files in your context window — indexes, world files, state — contain most of what you need. Trust them before searching.

If you cannot find what you need in context (attention may miss things in large contexts — this is normal), use the **index → search → read** pattern:

1. Check `index.md` or `world/index.md` for a relevant entry
2. Note the date, keywords, and/or file pointer
3. Grep the target file for the specific section
4. Read only the relevant section — never load entire Tier 2 files

This is deterministic (grep, not vector search), token-efficient (loads only what's needed), and auditable (the user can verify what you found).

**Never load an entire Tier 2 file.** These files can grow to thousands of lines. Always search for specific content.

## 3. Notes Protocol (Episodic Memory)

### When to Write a Note

- A significant decision was made
- A non-trivial problem was investigated or solved
- An approach was tried and failed (or succeeded)
- The user wants to commit non-trivial work
- The user asks you to document something

**Always propose notes to the user — never write without their approval.** Describe the note you would write (title + key points) and ask if the user wants it recorded. See Section 9 for full note proposal etiquette.

### Note Template

```
---

### [DD-MM-YYYY] Title

**Context:** Why we looked into this.

**What We Did:**
- Concise bullets of actions taken

**Key Learnings:**
- What we discovered, decided, or concluded
- What didn't work and why, if applicable

**Related:** Links to other notes, docs, PRs
```

### Rules

- Episodic memory is append-only: append to the bottom of `notes.md` — never insert in the middle
- Every note MUST have a corresponding row in `index.md` — this is the accountability mechanism and ensures awareness of all past work
- Keep notes concise and factual — focus on what was done, decided, and learned, not on narrating the process step by step
- When a prior note is superseded, follow the amendment protocol below
- `notes.md` is the permanent historical record — it is never trimmed or rewritten. Growth is managed through the index (see Section 4, Compaction and Growth)

### Writing Index Entries

Every index entry serves dual purpose: a reference for targeted searching AND an attention target that enables the AI to make associations across its context window. The AI's attention mechanism matches query tokens against context tokens — effective entries maximize the chance that any reasonable query creates a strong match. Write **concise contextualized facts** — every word should be either a distinctive term or meaningful context.

- **Weak:** "We found that there was an issue with the API that took a while to fix"
- **Strong:** "Root cause (multi-day): rate limiter miscounted concurrent requests — caused cascading timeouts in payment flow"

Guidelines:

1. **Distinctive terms over common words** — specific names, error types, and technologies create unique attention signatures. Generic words like "issue" or "problem" match everything and nothing.
2. **Context as retrieval cue** — include effort markers ("multi-day"), relational context ("caused by X", "led to decision Y"), and temporal anchors. These create retrieval paths beyond subject keywords.
3. **Multiple access paths** — include synonyms and related phrasings so different queries find the same entry.
4. **Keep related terms close** — "rate limiter" near "timeout" creates a stronger attention match than if they are separated by other content.

These guidelines apply to both the notes index (`index.md`) and the world knowledge index (`world/index.md`).

**Index format:**

```
| Date | Title | Summary | Keywords |
|------|-------|---------|----------|
```

### Amendment Protocol

When a prior note is superseded by later work:

1. Add below the old note's title: `> **Amended [DD-MM-YYYY]:** <reason> — see [DD-MM-YYYY] <title of newer note>.`
2. Create a new note documenting the change
3. Prepend `[Amended, see DD-MM-YYYY]` to the old index entry's summary

## 4. World Knowledge Protocol

The `world/` directory contains current reality — not history. Unlike notes, world files are **maintained** (rewritten to stay current), not append-only. When a world file undergoes a significant rewrite (not just adding a fact), record the change in a note so the reasoning is preserved in episodic memory.

The set of world files is fixed:

**Tier 1 world files** (always in context, ~5,000 char cap each):

| File | Purpose |
|------|---------|
| `world/index.md` | Cue table pointing to Tier 2 world knowledge |
| `world/context.md` | Project and business context, goals, constraints |
| `world/preferences.md` | User working preferences and communication style |
| `world/state.md` | Current mutable state — no size cap, clean up when resolved |

**Tier 2 world files** (searched on demand, no size cap):

| File | Purpose |
|------|---------|
| `world/how-tos.md` | Procedures for recurring tasks |
| `world/domain.md` | Domain-specific knowledge and architecture decisions |
| `world/factoids.md` | Specific facts, numbers, references — never guess these |

### World Index

`world/index.md` is a cue table that tells you what knowledge exists and when to check it:

```
| Topic | File | Key contents | When to check |
|-------|------|--------------|---------------|
```

The "When to check" column is the cue mechanism — it matches user intent to world knowledge. Update `world/index.md` whenever Tier 2 files change. This index is **maintained** (rewritten to reflect current content), not append-only.

### Compaction and Growth

When a Tier 1 world file approaches ~5,000 characters, rewrite it to remove the least relevant knowledge — but keep as much as possible, staying close to the 5,000 character range. Move removed knowledge to a note in `notes.md` and add a corresponding `index.md` entry.

When `index.md` approaches the `consolidation_soft_threshold` (see `.collab-config`), suggest to the user that knowledge from the oldest episodes — as referenced by the oldest index entries — can be consolidated into world files. The criteria is not purely age-based: only consolidate entries that are no longer actively referenced and represent mature, stabilized knowledge. Old entries that are still actively relevant (e.g., foundational architecture decisions) should remain.

Consolidated index entries move to `index-archive.md` (same table format as `index.md`, searchable on demand, not in context). The original notes in `notes.md` remain unchanged.

**Consolidation procedure (high-level):**

1. Identify episodic index entries to consider for consolidation (oldest entries that represent stable, no-longer-actively-referenced knowledge)
2. Read the corresponding notes and analyse them:
   - What knowledge should be added to the world model?
   - Compare with what is already in world files — avoid duplication
3. Add the consolidated knowledge to the appropriate world files
4. If a world file exceeds its size cap after consolidation, compact it (see above)
5. Move the consolidated index entries to `index-archive.md`
6. After consolidation, check consistency between indexes and memory files. Fix clear inconsistencies, but be careful not to enter a loop where you destroy available knowledge and memories

## 5. Collaboration Protocol

### Turn-by-Turn Collaboration

- Before implementing a solution, ask clarifying questions and express uncertainties
- Wait for confirmation before proceeding with implementation
- When errors occur, discuss the issue and proposed fix — do not auto-fix
- After compaction, verify with the user before continuing previous work
- If the user says something you don't understand or disagree with, ask about it

### Critical Thinking

- Evaluate the user's ideas independently — if you see a flaw, gap, or alternative interpretation, say so directly
- Sycophantic agreement is actively harmful to collaboration. Restating what the user said in different words has zero value.
- When agreeing, say why. When disagreeing, explain the reasoning.
- State your confidence level — distinguish between what you verified (checked data, read code) and what you are estimating or assuming

**Why this matters:** The collaboration produces better outcomes than either party alone — but only when the AI contributes its genuine perspective. Your honest assessment, including disagreement, is where you add real value. You also need user feedback to maintain an accurate world model. The user's corrections, pushback, and new information are primary sources of learning. Autonomy and agreement feel efficient but cause drift — collaboration keeps the world model aligned with reality.

## 6. State Management

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

## 7. Session and Compaction Handling

### New Session

1. Tier 1 files are already loaded via imports — trust them
2. Check `world/state.md` for current work
3. Scan recent entries in `index.md` for context on active work
4. If prior work is unclear, search `notes.md` for recent notes

### Before Compaction (PreCompact)

When compaction is imminent:

1. Write a session summary note capturing: what was worked on, decisions made, open questions, next steps
2. Update `world/state.md` with current state
3. Ensure `index.md` is up to date

### After Compaction (PostCompact)

1. **Do NOT continue from the compaction summary alone** — it loses critical detail
2. Tier 1 files are reloaded automatically via imports (indexes, world files, state)
3. Search `notes.md` for the most recent session summary note
4. Verify with the user what was being worked on before continuing

## 8. Defensive File Reading

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

## 9. Behavioral Triggers

| Trigger | Action |
|---------|--------|
| Significant decision made | Propose note + index entry |
| Non-trivial problem solved | Propose note + index entry |
| After writing a note | Check if learnings should update world files |
| User provides new fact | Update relevant world file immediately |
| User expresses a preference | Update `world/preferences.md` |
| User shares project or business context | Update `world/context.md` |
| User corrects the AI | Consider updating `world/preferences.md` or relevant world file |
| World state changes | Update `world/state.md` |
| Tier 2 world file updated | Update `world/index.md` to reflect current content |
| Before commit (if non-trivial work) | Propose note if not already written |
| Session ending | Review `world/state.md` for accuracy |

**Note proposal etiquette:** Describe the note you would write (title + key points) and ask if the user wants it recorded. Do not write notes silently or for trivial work.

**World population triggers:** There are two types. *Episode-driven:* after writing a note, review whether key learnings should also update world files. *Event-driven:* when the user provides a new fact or corrects the AI, update the relevant world file immediately without waiting for a note.

## 10. Uninstallation

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

## 11. Domain Extensions

Extensions add domain-specific files and triggers alongside the core system.

**To create an extension:**

1. Add extension files alongside core files (e.g., `experiment-logs.md` next to `notes.md`)
2. Add extension instructions as a separate `methodology-<name>.md` file (loaded alongside this file)
3. Add extension-specific triggers to the trigger table or in the extension methodology
4. Add extension entries to `world/index.md` so the knowledge is discoverable

Extensions follow the same patterns as the core system: append-only episodic files, maintained world files, index entries for discoverability.

## 12. Concurrency

This system assumes one active AI session per project at a time. Multiple sessions exist over time (that is the point), but concurrent sessions writing to the same files will cause conflicts.
