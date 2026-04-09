# ai-collab-memory

ai-collab-memory is a simple, easy-to-use, yet powerful memory system enabling long-term collaboration between
humans and AI assistants. It's easy to install as well!

The memory is file-based and represented as plain text (easy to inspect), can be
git-tracked (storage & versioning) and can be used to build up knowledge within a team of users.
So no databases, no vector stores, no infrastructure. 
Just files and a methodology that the AI follows.

Through the use of in-context memory index files, the AI can maintain a global awareness of what's in the memory.

The system can, in principle, be integrated into any AI system, but so far it has been optimised for use 
with Claude Code.

## Help Us Improve This System

**Status:** v1.6 — we are actively testing and developing this. The episodic memory (notes, index) is the more mature component; the world model memory is functional but earlier in its development. We welcome you to try it and share your experience — what worked, what didn't, what's missing. Your feedback directly shapes what we build next. File issues or experience reports at https://github.com/visionscaper/ai-collab-memory/issues.

All testing and development so far has been done using Claude Opus 4.6. This system relies on the AI's ability to follow nuanced instructions, maintain context awareness, and make judgement calls about when to write notes and update the world model — capabilities that may not be available in smaller or less powerful models.

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

## How to Upgrade

### For AI Assistants

If a user asks you to upgrade the collaboration memory system, read [`upgrade.md`](upgrade.md) and follow the step-by-step instructions.

### For Humans

Ask your AI assistant:

> "Upgrade the collaboration memory system by cloning https://github.com/visionscaper/ai-collab-memory to a temporary location and following the upgrade instructions in it."

The AI will compare your installed version with the latest, read the release notes, and apply the differences. Your notes, world model, and accumulated knowledge are never modified during an upgrade — only system files (methodology, hooks, configuration) are updated. In rare cases where memory data needs to be adapted to a new version, the AI will discuss the changes with you and ask for approval before making any modifications.

## What Gets Installed

The system adds a collaboration directory (default `collab/`) to the project:

```
.collab-config                  ← system settings (at project root)
collab/
├── .collab-memory-system       ← version marker
├── methodology.md              ← AI operating instructions
├── index.md                    ← episodic memory index (Tier 1 — always in context)
├── notes.md                    ← episodic memory (Tier 2 — searched on demand)
├── index-archive.md            ← archived index entries (Tier 2)
├── docs/                       ← long-form reference documents (Tier 2)
└── world/
    ├── index.md                ← world model index (Tier 1)
    ├── context.md              ← personal, project, business context (Tier 1)
    ├── preferences.md          ← user working preferences (Tier 1)
    ├── state.md                ← current work in progress, todos, blockers (Tier 1)
    ├── how-tos.md              ← procedures for recurring tasks (Tier 2)
    ├── domain.md               ← domain-specific knowledge (Tier 2)
    └── factoids.md             ← specific facts, numbers, references (Tier 2)
```

Imports are added to the project's instruction file (e.g., `CLAUDE.md`, `.cursorrules`) so the AI loads memory automatically. Platform-specific lifecycle hooks are installed where supported (currently Claude Code).

All files are git-tracked (in the code repo for solo installations, or in the shared-knowledge repo for team installations — see "Distributed Collaboration" below). Nothing is hidden or opaque.

## Introduction

In order to collaborate long-term with AI in an effective way, there needs to be a shared conceptual understanding about:
 * history (episodic memory): what has been done, why, how and what decisions were made over time? What did we learn?
 * reality (world model): what is the context of the work being done, what is the project about, for what business, why?
   What is the current state of the work? How should the work be done in general, what are the guidelines and preferences?
   What are the constraints? Etc.

Without this kind of conceptual knowledge, AI can't do its work effectively, especially over long periods,
i.e. weeks, months, or even years. It would need to rediscover information at every session.
Further, without all this context it would not effectively respond or make optimal choices when working
(e.g. when writing code or creating a design).

ai-collab-memory enables the build-up of **Episodic memory** and a **World model** over time.
Entries in this memory are summarized in an index which is always in the AI context window, allowing the model to have a
global **awareness** of everything that is in the memory. This allows it to cross-correlate knowledge in this memory
and to know where to find details from memory entries.

The system uses three sentinel tokens — `readmem`, `updatemem`, and `maintainmem` — as the primary way to interact with memory. Include them in your message to the AI to trigger reading from memory, updating it, or maintaining it. The AI proposes what to read or write; you approve. In this way a high-quality memory with conceptual knowledge is built up over time. And we keep the memory system simple, without needing custom agentic AI solutions or infrastructure.

ai-collab-memory has a methodology to ensure that episodic or world model memory is never lost. See the section
"How It Works" for more details.

## Working with the Memory System

The system provides three sentinel tokens for interacting with memory — include them in your message to trigger the corresponding operation:

- **`readmem`** — Read relevant information from memory before handling a task. Use when you need background, history, or context from prior work.
- **`updatemem`** — Evaluate what should be captured in memory — as a note, a world model update, or both. Use after discussions that produced decisions or learnings, after completing work, or when you've shared context that should be remembered.
- **`maintainmem`** — Evaluate whether memory maintenance is needed — consolidating old index entries into the world model, or compacting world files that have grown too large.

**Example usage:**

> Fix the auth bug in the login flow. readmem

> That went well, we're done. updatemem

> The index is getting long. maintainmem

You'll get the most out of the memory system by developing the habit of using the sentinel tokens at natural moments — `readmem` when starting work that needs context, `updatemem` when something worth remembering just happened, `maintainmem` when the index feels cluttered.

The methodology defines three levels of triggers that can activate memory operations:

1. **Sentinel tokens (strongest guarantee)** — When `readmem`, `updatemem`, or `maintainmem` is present in your message, the AI MUST perform the operation.
2. **Word cues** — Words like "done", "decided", "background", "history" may prompt the AI to read from or update memory without an explicit sentinel token.
3. **Conceptual triggers** — The AI is instructed to recognise situations where memory operations are appropriate, such as when a logical unit of work concludes.

The word-level and conceptual triggers allow the AI to act on its own, but in practice automatic triggering is unreliable during focused execution due to attention drift. The sentinel tokens solve this — they're the reliable mechanism you can always count on.

This design means the system works with any AI assistant that can read and write local files — no custom agentic infrastructure required. The sentinel tokens are just words in your message that the AI's methodology tells it to act on. Building a customised agentic system where detection of these triggers is more automated is future work.

**Elaborate documents for significant work:** When a discussion or investigation produces rich, detailed content — an analysis, a design, a comparison study — ask the AI to write it as a standalone document in `collab/docs/`. The note and/or world model entry can then reference the document rather than trying to compress everything into a note. This keeps notes concise while preserving depth where it matters.

### IMPORTANT: Watch for automatic context compaction

AI systems such as Claude Code don't know how much context window space remains before auto-compaction occurs. When compaction happens, session details are lost — only the memory system's files preserve what was discussed and decided. When you notice the context window space is getting low, tell the AI: "compaction soon, updatemem". This is your best insurance against losing session context.

## How It Works

### Three Memory Types

| Type | Purpose | Files |
|------|---------|-------|
| **Episodic** | What happened, what was decided, why | `notes.md`, `docs/` |
| **World model** | Current understanding of reality | `world/` directory |
| **Working memory** | What's loaded in the AI's context window | Managed via tiers |

Episodic memory is **append-only** — notes are never rewritten, preserving the historical record. A note from month 1 describing code that was rewritten in month 3 isn't stale — it's history, and the reasoning behind that original design might matter later. When a note is superseded, an amendment links it to the newer note. The world model is **maintained** — files are updated to reflect current reality. Staleness is handled differently by type: episodic memory preserves history, the world model stays current.

### Two-Tier Context Management

Not everything can fit in the AI's context window. The system uses two tiers:

- **Tier 1 (always in context):** The episodic index, world model index, and core world files (context, preferences, state). These are kept compact (~5,000 characters each).
- **Tier 2 (searched on demand):** Detailed notes, reference documents, and extended world knowledge (how-tos, domain, factoids). These grow without limit.

### Awareness, Not Just Retrieval

Most memory tools treat recall as a retrieval problem: store knowledge somewhere, search it when needed. This requires the AI to already know what it's looking for.

ai-collab-memory takes a different approach. The Tier 1 indexes — compact tables of past episodes and world knowledge — are always loaded in the AI's context window. Because the AI's attention mechanism matches query tokens against context tokens, these indexes create continuous **awareness** of accumulated knowledge. The AI can make associations and connections to prior work without an explicit search query — it knows a topic exists before it needs to look it up.

When details are needed, the AI uses a precise **index → search → read** pattern: find the relevant index entry, grep the target file, read only the relevant section. No vector search, no embeddings — just structured text and grep.

### Multi-User Support

The system is designed for teams from the ground up. Every note and index entry includes user attribution. World model files use per-user sections where appropriate (personal context, preferences, current work), allowing git to auto-merge changes from different users. A merge resolution protocol handles conflicts in shared world files.

### Distributed Collaboration

An interesting use case of this memory system is building up shared memory in a team or organisation. Each team member contributes to the same episodic history and world model; new members get up to speed through the AI's accumulated knowledge; cross-project learnings can be referenced.

**Why memory often shouldn't live in the same repo as the code:**

- **Branch divergence** — developers on long-lived branches diverge from the memory on main; merge conflicts accumulate as work progresses.
- **Public repos** — project decisions, business context, user preferences, and strategic discussions shouldn't be publicly visible.
- **Access control** — team members may have different access to different projects; per-project memory isolation matters.
- **Repo churn** — code changes often don't warrant memory updates; mixing them clutters PR history.
- **Memory as first-class history** — memory changes deserve their own commit history and review flow, separate from code.

**Two patterns for distributed memory:**

- **Single shared-knowledge repo** — one repo containing all projects, e.g. `shared-knowledge/collab/project-x/`, `shared-knowledge/collab/project-y/`. The top-level `collab/` directory groups all collab memory, leaving room for other organisational content (architecture docs, team playbooks, policies) alongside it. Centralises team knowledge, simplifies cross-project awareness, single ACL to manage. Good default for most teams.
- **Per-project memory repo** — one memory repo per project. Use this when different projects have different teams with different access levels, or when projects must stay fully isolated (e.g., client confidentiality, regulatory boundaries).

In both patterns, the code repo contains a symlink named `collab` (git-ignored; each dev creates their own) pointing to the external memory directory. This keeps `.collab-config`, the import block, and all `@collab/...` paths identical between solo and team installations. The installation procedure guides the user through the team/solo decision, repo setup (including `gh` assistance if available), and symlink creation.

### Memory Growth and Sustainability

As collaboration continues, memory grows. Two mechanisms keep this sustainable without losing knowledge:

- **Episodic index consolidation (upward)** — When the episodic index grows large, mature stable knowledge from old episodes is extracted into world model files. The consolidated index entries move to a searchable archive. The original notes remain unchanged. This keeps the active index focused on recent work while the world model absorbs the accumulated knowledge.
- **World model compaction (downward)** — When a world model file approaches its size cap, it is rewritten to stay compact. Removed knowledge is preserved in an episodic note, so nothing is lost.

Both mechanisms preserve knowledge — nothing is deleted. Consolidation and compaction are always discussed with the user before being applied.

## What Makes This Different

ai-collab-memory is optimized to build up and maintain memory for long-term collaboration. 
So, the focus is on capturing conceptual knowledge that helps the AI (and the user) to effectively work together over 
weeks, months, or even years. Further, the system is kept simple, making it easy to install, use, inspect, store and version.
Through its simplicity it also enables advanced use cases where teams of users build up shared knowledge together while 
collaborating with AI.

What differentiates ai-collab-memory:
- **Collaborative knowledge through episodic memory and world model.** Memory is split into two complementary types: episodic memory (what happened, what was decided, why) and a world model (project context, domain knowledge, preferences, current state). Episodic memory preserves history; the world model captures what was *learned* from that history — the conceptual knowledge that makes collaboration effective. As episodes accumulate, mature knowledge consolidates into the world model, so understanding compounds over time and the AI *grows* as a collaborator.
- **Rich, detailed conceptual knowledge.** ai-collab-memory captures detailed episodic records: context, actions taken, key learnings, reasoning, what was considered and decided against. A fresh AI session doesn't just see *what* happened — it sees *why*, which alternatives were considered, and what reasoning led to each decision. This depth is what makes the AI an effective long-term collaborator rather than a tool that needs re-explaining.
- **User-verified knowledge quality.** Automated memory extraction captures what the model *thinks* is important. User-reviewed memory captures what *actually* is important — the user knows their own context, priorities, and what matters for the work. Notes require user approval. World model updates are visible and editable. This produces more accurate, more relevant knowledge that stays aligned with reality.
- **History preserved, not pruned away.** Episodic memory is append-only — the historical record is never rewritten. The world model is maintained separately — rewritten to reflect current reality. This separation means you can trace back to why a decision was made months ago, what alternatives were considered, and how understanding evolved.
- **Multi-user collaboration by default.** Every note includes user attribution. World model files use per-user sections for git-friendly concurrent collaboration. Merge resolution is built into the methodology. Platform-native memory is typically per-user with no team features.
- **Platform-independent and git-tracked.** Plain text markdown in the project repo, version-controlled alongside the code. Works with any AI assistant that can read and write files — no custom agentic infrastructure required. The sentinel tokens are just words in your message that the methodology tells the AI to act on, so the system works out of the box on any platform. Every change is auditable through git history. No vendor lock-in, no opaque storage. Plain text is the most portable knowledge format — a raw material that any current or future AI platform can consume. Databases, vector stores, and proprietary formats are tied to the platforms that created them.

These distinctions compound over time. The longer the collaboration, the more valuable rich history, user-verified knowledge, and shared understanding become. For simple preference tracking on individual projects, platform-native memory may be enough. For long-term collaboration — weeks, months, years — where the AI needs deep contextual understanding to contribute meaningfully, that's where this system adds real value.

## Requirements and Compatibility

**Prerequisites:**
- An AI assistant that can read and write local files and load an instruction file into context (e.g., CLAUDE.md, `.cursorrules`)
- Git is recommended for version control and auditability, but not a hard requirement — the system works without it if you prefer to keep everything local

**Platform support:**

| Platform | Core system | Lifecycle hooks |
|----------|-------------|-----------------|
| Claude Code | Full support | SessionStart, UserPromptSubmit |
| Other AI assistants | Full support (methodology is self-contained) | Not yet available — hooks enhance but are not required |

The core methodology works with any AI assistant that can read and write files across sessions and load an instruction file into context. This includes CLI tools (Claude Code), IDE integrations, and web-based AI assistants with file access (e.g., Claude Cowork — untested but likely compatible). Hooks add session management (timestamps, health checks, context recovery reminders) but are optional. On platforms without hooks, the AI has no automatic signal for new sessions or compaction — use `readmem` explicitly at the start of a session to trigger context recovery.

## Current Limitations and Status

**Maturity:** The episodic memory system (notes, index, two-tier retrieval) is the more developed component — it has been used across multiple projects over several months. The world model memory (world files, consolidation, maintenance) is functional but earlier in its development. The overall system is being actively tested and refined.

**Known limitations:**
- **Context window dependency** — Tier 1 files must fit in the AI's context window alongside other instructions and conversation. The ~5,000 character caps are tuned for current context sizes but may need adjustment.
- **No automated consolidation** — When the episodic index grows large, the AI suggests consolidation but the process is manual (AI-assisted, user-approved). Automated tooling is future work.
- **Hook support** — Lifecycle hooks are currently implemented for Claude Code only. Other platforms might be added in the future. If you are interested in support for a specific platform, provide your solution in a PR or file an issue (see Contributing).
- **Single methodology version** — No automated migration tooling between methodology versions. Manual upgrade instructions are in [`upgrade.md`](upgrade.md).
- **Instruction file reload** — Most AI platforms only load the instruction file at session start. Changes made during installation take effect in the next session, not immediately.
- **Automatic reflection is best-effort** — The methodology defines word-level and conceptual triggers for automatic memory operations, but these are unreliable during focused execution due to attention drift. Sentinel tokens (`readmem`, `updatemem`, `maintainmem`) solve the user-driven side — when present, the AI must act. For fully automatic reflection, the ideal solution is a separate reflection agent that monitors the conversation independently of the main execution agent — separating the execution concern from the reflection concern. This is architecturally viable (Claude Code's Stop hook provides transcript access, and the Agent SDK enables subagents) but is future work.

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
