# ai-collab-memory

A structured methodology for long-term collaboration between humans and AI assistants.

## Introduction

AI assistants today have no meaningful long-term memory. Each session starts nearly blank, and within a session, context compaction discards detail as the conversation grows. This makes genuine collaboration — over days, weeks, months, or even years — impossible. The AI repeatedly rediscovers information, forgets decisions, and contradicts prior work. It never builds the contextual understanding needed for informed suggestions, and cannot draw on accumulated experience for creative solutions.

**ai-collab-memory** solves this with two types of persistent, file-based memory:

- **Episodic memory** — a historical record of what happened, what was decided, and why. Notes capture significant work, decisions, investigations, observations, and learnings. An index provides a compact overview.
- **World model** — the AI's current understanding of reality. Context about the project, user preferences, active state, domain knowledge, procedures, and facts. Updated as the AI learns new knowledge about the world, or when the world changes.

Both memory types are plain text files, tracked in git alongside the project. Everything is human-readable, auditable, and version-controlled. The system works for individuals and for teams collaborating on a shared project — user attribution and merge resolution are built in.

No databases, no vector stores, no infrastructure. Just files and a methodology that the AI follows.

**Status:** v1.0 — actively used, feedback welcome.

## What Gets Installed

The system adds a collaboration directory (default `collab/`) to the project:

```
.collab-config                  ← system settings (at project root)
collab/
├── .collab-memory-system       ← version marker
├── methodology.md              ← AI operating instructions
├── index.md                    ← episodic memory index (compact cue table)
├── notes.md                    ← episodic memory (detailed notes)
├── docs/                       ← long-form reference documents
└── world/
    ├── index.md                ← world model index (cue table)
    ├── context.md              ← personal, project, business context
    ├── preferences.md          ← user working preferences
    ├── state.md                ← current work in progress, todos, blockers
    ├── how-tos.md              ← procedures for recurring tasks
    ├── domain.md               ← domain-specific knowledge
    └── factoids.md             ← specific facts, numbers, references
```

Imports are added to the project's instruction file (e.g., `CLAUDE.md`, `.cursorrules`) so the AI loads memory automatically. Platform-specific lifecycle hooks are installed where supported (currently Claude Code).

All files are git-tracked. Nothing is hidden or opaque.

## How to Install

### For AI Assistants

If a user asks you to install this system, read [`install.md`](install.md) and follow the step-by-step instructions. The installation guide covers:

- Assessing the existing project setup
- Confirming the plan with the user
- Creating all memory files from templates
- Configuring imports in the instruction file
- Installing platform-specific hooks
- Optional initial world population
- Verification

### For Humans

Ask your AI assistant to install the system:

> "Install the long-term collaboration memory system from https://github.com/visionscaper/ai-collab-memory"

The AI will read this README, find the installation instructions, and walk you through setup. You'll be asked to confirm before any changes are made. The default installation takes a single confirmation — customization is available if needed.

Alternatively, clone the repository and point your AI assistant to `install.md`:

```bash
git clone https://github.com/visionscaper/ai-collab-memory.git
```

## How It Works

### Three Memory Types

| Type | Purpose | Files |
|------|---------|-------|
| **Episodic** | What happened, what was decided, why | `notes.md`, `docs/` |
| **World model** | Current understanding of reality | `world/` directory |
| **Working memory** | What's loaded in the AI's context window | Managed via tiers |

Episodic memory is **append-only** — notes are never rewritten, preserving the historical record. The world model is **maintained** — files are updated to reflect current reality.

### Two-Tier Context Management

Not everything can fit in the AI's context window. The system uses two tiers:

- **Tier 1 (always in context):** The episodic index, world model index, and core world files (context, preferences, state). These are kept compact (~5,000 characters each).
- **Tier 2 (searched on demand):** Detailed notes, reference documents, and extended world knowledge (how-tos, domain, factoids). These grow without limit.

### Awareness, Not Just Retrieval

Most memory tools treat recall as a retrieval problem: store knowledge somewhere, search it when needed. This requires the AI to already know what it's looking for.

ai-collab-memory takes a different approach. The Tier 1 indexes — compact tables of past episodes and world knowledge — are always loaded in the AI's context window. Because the AI's attention mechanism matches query tokens against context tokens, these indexes create continuous **awareness** of accumulated knowledge. The AI can make associations and connections to prior work without an explicit search query — it knows a topic exists before it needs to look it up.

When details are needed, the AI uses a deterministic **index → search → read** pattern: find the relevant index entry, grep the target file, read only the relevant section. No vector search, no embeddings — just structured text and grep.

### Multi-User Support

The system is designed for teams from the ground up. Every note and index entry includes user attribution. World model files use per-user sections where appropriate (personal context, preferences, current work), allowing git to auto-merge changes from different users. A merge resolution protocol handles conflicts in shared world files.

### Behavioral Triggers

The methodology defines when the AI should act: propose a note after a significant decision, update world files when the user shares new facts or preferences, check state at session boundaries, suggest consolidation when the index grows large. These triggers ensure the memory grows organically through normal collaboration — no manual maintenance required.

## Requirements and Compatibility

**Prerequisites:**
- A git-tracked project
- An AI assistant that supports an instruction file mechanism (e.g., CLAUDE.md, .cursorrules)

**Platform support:**

| Platform | Core system | Lifecycle hooks |
|----------|-------------|-----------------|
| Claude Code | Full support | SessionStart, UserPromptSubmit |
| Other AI assistants | Full support (methodology is self-contained) | Not yet available — hooks enhance but are not required |

The core methodology works with any AI assistant that can read and write files and load an instruction file into context. Hooks add session management (timestamps, health checks, context recovery reminders) but are optional.

## Current Limitations

- **Context window dependency** — Tier 1 files must fit in the AI's context window alongside other instructions and conversation. The ~5,000 character caps are tuned for current context sizes but may need adjustment.
- **No automated consolidation** — When the episodic index grows large, the AI suggests consolidation but the process is manual (AI-assisted, user-approved). Automated tooling is future work.
- **Hook support** — Lifecycle hooks are currently implemented for Claude Code only. Other platforms might be added in the future. If you are interested in support for a specific platform, provide your solution in a PR or file an issue (see Contributing).
- **Single methodology version** — No migration tooling yet between methodology versions. Upgrade instructions will be provided in `upgrade.md` when needed.
- **Instruction file reload** — Most AI platforms only load the instruction file at session start. Changes made during installation take effect in the next session, not immediately.

## Contributing

This project is in early development. Contributions, feedback, and experience reports are welcome.

**Filing issues:** https://github.com/visionscaper/ai-collab-memory/issues

Use issues for:
- Bug reports (installation failures, methodology gaps, hook issues)
- Feature requests (new platforms, domain extensions, tooling)
- Experience reports (what worked, what didn't, what's missing)

**Contributing code or documentation:**
- Fork the repository and submit a pull request
- For significant changes, open an issue first to discuss the approach
- The methodology (`collab/methodology.md`) and installation instructions (`install.md`) are the most critical files — changes to these should be discussed before implementation

## License

Apache License 2.0 — see [LICENSE](LICENSE).
