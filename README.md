# ai-collab-memory

A structured methodology for long-term collaboration between humans and AI assistants.

## Introduction

AI platforms are adding memory features — preferences, session notes, automated memory extraction. These help with session-to-session continuity for individual developers: remembering build commands, framework choices, and working preferences. But they optimise for brevity and automation — short entries, aggressive pruning, minimal user involvement.

For genuine long-term collaboration — over weeks, months, or years — this isn't enough. The AI needs rich contextual understanding: not just *what* was decided, but *why*, what alternatives were considered, how understanding evolved, and what the user's goals and constraints are. It needs memory that's detailed enough to reason from, accurate enough to trust, and persistent enough to build on. Without this, the AI repeatedly rediscovers context, loses the reasoning behind decisions, and cannot draw on accumulated experience.

**ai-collab-memory** solves this with two types of persistent, file-based memory:

- **Episodic memory** — a historical record of what happened, what was decided, and why. Notes capture significant work, decisions, investigations, observations, and learnings. An index provides a compact overview.
- **World model** — the AI's current understanding of reality. Context about the project, user preferences, active state, domain knowledge, procedures, and facts. Updated as the AI learns new knowledge about the world, or when the world changes.

Both memory types are plain text files, tracked in git alongside the project. Everything is human-readable, auditable, and version-controlled. The system works for individuals and for teams collaborating on a shared project — user attribution and merge resolution are built in.

No databases, no vector stores, no infrastructure. Just files and a methodology that the AI follows.

## Help Us Improve This System

**Status:** v1.1 — we are actively testing and developing this. The episodic memory (notes, index) is the more mature component; the world model memory is functional but earlier in its development. We welcome you to try it and share your experience — what worked, what didn't, what's missing. Your feedback directly shapes what we build next. File issues or experience reports at https://github.com/visionscaper/ai-collab-memory/issues.

All testing and development so far has been done using Claude Opus 4.6. This system relies on the AI's ability to follow nuanced instructions, maintain context awareness, and make judgement calls about when to write notes and update the world model — capabilities that may not be available in smaller or less powerful models.

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

Ask your AI assistant:

> "Install the long-term collaboration memory system by cloning https://github.com/visionscaper/ai-collab-memory to a temporary location and following the instructions in it."

The AI will clone the repository, read the installation instructions, and walk you through setup. You'll be asked to confirm before any changes are made. The default installation takes a single confirmation — customization is available if needed.

## Working with the Memory System

You, as the user, know best when something important was discussed, decided, or learned. Prompting the AI for memory updates at natural checkpoints is the most reliable way to keep the memory system current and useful:

- After a discussion that produced decisions, a design, or a plan
- After completing a piece of work (feature, fix, refactor, investigation)
- Before committing non-trivial changes
- When you've shared context, preferences, or corrections that should be remembered
- At the end of a session

The methodology instructs the AI to proactively propose notes and world model updates, but in practice this is unreliable — especially during focused execution. Current AI models allocate attention to the immediate task and deprioritize reflective meta-tasks like "should I update memory now?" This is not a bug in the instructions; it's a fundamental limitation of how current models process competing priorities. Don't rely on the AI to suggest updates — prompt for them yourself when the moment is right.

**Example prompts:**

> Please write a note about what we did, learned, and/or decided. Include an index entry as well.

> Please update the world model with relevant knowledge from what we did, learned, and decided. Update the world model index too if you changed any Tier 2 files.

> Please update the current state with what we're working on and any open items.

These are examples — phrase them however feels natural. The AI understands the underlying system and will route information to the right files.

### IMPORTANT: Watch for automatic context compaction

The AI cannot know how much context window space remains before auto-compaction occurs. When compaction happens, session details are lost — only the memory system's files preserve what was discussed and decided. When you notice the context window space is getting low, ask the AI to write a note capturing current session state — decisions made, work in progress, open questions. This is your best insurance against losing session context.

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

## What Makes This Different

AI platforms are adding memory features — auto-memory, memory consolidation, session notes. These systems share several core concepts with ai-collab-memory: in-context indexes for awareness, tiered storage (always-loaded vs on-demand), and consolidation of accumulated knowledge. Some go further with automated per-turn memory extraction and background consolidation. For a single developer on routine tasks, platform-native memory works well.

ai-collab-memory addresses a different problem: **collaboration-level memory** for extended projects, enabling long-term collaboration between the AI and the user(s). The differences are about depth, quality, and purpose — not just architecture:

- **Rich, detailed knowledge instead of brief pointers.** Platform memory systems optimise for minimal footprint — short entries, aggressive pruning, don't store what you can derive. ai-collab-memory captures detailed episodic records: context, actions taken, key learnings, reasoning, what was considered and decided against. A fresh AI session doesn't just see *what* happened — it sees *why*, which alternatives were considered, and what reasoning led to each decision. This depth is what makes the AI an effective long-term collaborator rather than a tool that needs re-explaining.
- **User-verified knowledge quality.** Automated memory extraction captures what the model *thinks* is important. User-reviewed memory captures what *actually* is important — the user knows their own context, priorities, and what matters for the work. Notes require user approval. World model updates are visible and editable. This produces more accurate, more relevant knowledge that stays aligned with reality.
- **History preserved, not pruned away.** Episodic memory is append-only — the historical record is never rewritten. The world model is maintained separately — rewritten to reflect current reality. This separation means you can trace back to why a decision was made months ago, what alternatives were considered, and how understanding evolved. Platform systems that "aggressively prune" and "continuously edit" memory destroy this historical context by design.
- **Multi-user collaboration by default.** Every note includes user attribution. World model files use per-user sections for git-friendly concurrent collaboration. Merge resolution is built into the methodology. Platform-native memory is typically per-user with no team features.
- **Platform-independent and git-tracked.** Plain text files in the project repo, version-controlled alongside the code. Works with any AI assistant that can read and write files. Every change is auditable through git history. No vendor lock-in, no opaque storage.

These distinctions compound over time. The longer the collaboration, the more valuable rich history, user-verified knowledge, and shared understanding become. For simple preference tracking on individual projects, platform-native memory may be enough. For long-term collaboration — weeks, months, years — where the AI needs deep contextual understanding to contribute meaningfully, that's where this system adds real value.

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

## Current Limitations and Status

**Maturity:** The episodic memory system (notes, index, two-tier retrieval) is the more developed component — it has been used across multiple projects over several months. The world model memory (world files, consolidation, maintenance) is functional but earlier in its development. The overall system is being actively tested and refined.

**Known limitations:**
- **Context window dependency** — Tier 1 files must fit in the AI's context window alongside other instructions and conversation. The ~5,000 character caps are tuned for current context sizes but may need adjustment.
- **No automated consolidation** — When the episodic index grows large, the AI suggests consolidation but the process is manual (AI-assisted, user-approved). Automated tooling is future work.
- **Hook support** — Lifecycle hooks are currently implemented for Claude Code only. Other platforms might be added in the future. If you are interested in support for a specific platform, provide your solution in a PR or file an issue (see Contributing).
- **Single methodology version** — No migration tooling yet between methodology versions. Upgrade instructions will be provided in `upgrade.md` when needed.
- **Instruction file reload** — Most AI platforms only load the instruction file at session start. Changes made during installation take effect in the next session, not immediately.
- **No automatic reflection** — The AI is instructed to proactively propose memory updates but often fails to during focused execution (see "Working with the Memory System" above). The ideal solution would be a separate reflection agent that monitors the conversation and surfaces "time for a note?" signals independently of the main execution agent — separating the execution concern from the reflection concern. This is not possible on current AI coding platforms (hooks lack conversation context, sub-agents must be manually invoked) but represents a direction for future development.

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
