# Collaboration Memory System — Installation

These instructions are for you, the AI assistant. Follow them step by step to install the collaboration memory system into the user's project. The system gives you long-term episodic and world model memory that survives across sessions and context compaction.

**What gets installed:**
- A collaboration directory (default `collab/`, user-configurable) with memory files (methodology, indexes, notes, world model)
- A `.collab-config` file at the project root
- Imports added to the project's instruction file (e.g., CLAUDE.md)
- Platform-specific lifecycle hooks (if supported)

**Repository structure reference:**
```
.collab-config              → project root
collab/
├── .collab-memory-system   (version marker)
├── methodology.md          (your operating instructions)
├── index.md                (episodic memory index — Tier 1)
├── notes.md                (episodic memory — Tier 2)
├── docs/                   (long-form reference documents — Tier 2)
│   └── .gitkeep
└── world/
    ├── index.md            (world model index — Tier 1)
    ├── context.md          (personal, project, business context — Tier 1)
    ├── preferences.md      (user working preferences — Tier 1)
    ├── state.md            (current mutable state — Tier 1)
    ├── how-tos.md          (procedures — Tier 2)
    ├── domain.md           (domain knowledge — Tier 2)
    └── factoids.md         (specific facts and references — Tier 2)
```

## Principles

These are hard rules. Follow them without exception.

1. **NEVER destroy or modify existing user content.** Do not overwrite, delete, or alter any existing files, instructions, or data without explicit user approval. All additions are clearly marked and placed alongside existing content.
2. **Flag conflicts, don't resolve them.** If you detect potential issues (existing instructions that contradict the methodology, duplicate hooks, conflicting file structures), report them to the user and ask how to proceed. Do not resolve conflicts unilaterally.
3. **Narrate every action.** Tell the user what you are doing at every step — what file you are creating, what content you are adding, what hook you are installing.
4. **Confirm before executing.** Describe what you will install, explain what each component is for, and ask for confirmation before making any changes.
5. **Suggest filing issues for unresolvable problems.** If you encounter a problem during installation that cannot be resolved without changes to the system itself (the methodology, templates, hooks, or installation procedure), suggest the user file an issue at https://github.com/visionscaper/ai-collab-memory/issues. Help draft the issue if the user wants.

## Prerequisites

You need local access to this repository's files to read the templates and copy them into the target project. If you are reading this file, you likely already have the repository cloned. If not, clone it first:

```
git clone https://github.com/visionscaper/ai-collab-memory.git /tmp/ai-collab-memory
```

## Installation Steps

### Step 1: Assess Existing Setup

Before doing anything, examine the target project:

1. **Instruction file** — Check if the project has an instruction file (e.g., `CLAUDE.md`, `.cursorrules`, or equivalent). Read its contents. Note:
   - Does it already contain collab-memory-system markers (`<!-- collab-memory-system:start -->`)?  If yes, the system is already installed — inform the user and stop.
   - Does it contain instructions that contradict the methodology (e.g., "never write notes", "don't ask questions")?  Flag these for the user.

2. **Existing hooks** — Check for hooks at two levels:
   - **Project level:** Check if `.claude/settings.json` (or equivalent) exists and contains hook definitions.
   - **Already running:** Look at `system-reminder` output in the current session for evidence of hooks already firing (e.g., timestamps, prompts, or other injected text on `SessionStart` or `UserPromptSubmit`). These may come from user-level or organization-level settings that are not visible in project files.

   Note any hooks on `SessionStart` or `UserPromptSubmit` events — these overlap with the collab system's hooks. See `hooks/claude-code/collab-memory-hook.sh` in this repository for the hooks that will be installed.

3. **Directory conflicts** — Check if `collab/` (or the chosen directory name) already exists at the project root. Check if `.collab-config` already exists.

4. **Existing notes or journaling** — Check if there are instructions that indicate the project uses a notes or journaling system (e.g., instructions to write notes, maintain a journal, update an index, or log experiments). Look for referenced files like `notes.md`, `dev-notes.md`, `journal.md`, `experiment-logs.md`, or sections in the instruction file that serve as a history of past work. Also check whether the instruction file acts as an index (keyword-rich summaries pointing to detailed files). If the user mentions an existing system, investigate its structure.

5. **Report findings** — Tell the user what you found: instruction file status, existing hooks, existing notes/journals, any conflicts. If there are conflicts, ask how to proceed before continuing.

### Step 2: Confirm with User

Ask the user a single question:

> "I'll install the collaboration memory system with recommended defaults into `collab/` at the project root, with imports at the end of your instruction file. All files will be git-tracked and human-auditable. Shall I proceed with defaults, or would you prefer to review customization options first?"

**If the user chooses defaults:** proceed to Step 3.

**If the user wants to customize**, present these options:

- **Directory location** — Default `collab/` at project root. The user can choose a different name or location. An alternative pattern is a **shared knowledge repository** — a separate repo dedicated to collaboration memory across multiple projects. Each project gets its own directory in the knowledge repo with a `collab/` subdirectory. This keeps code repos clean and centralizes collaboration knowledge. If the collab directory is outside the working repo, `.collab-config` still goes at the working repo root with `collab_dir` set to the absolute path of the collab directory. Ask the user whether `.collab-config` should be git-ignored — it may contain machine-specific paths, or the user may prefer not to commit any collab system references in the code repo.
- **Import placement** — Where to insert the import block in the instruction file. Options:
  - (a) At the end of the file (default — existing project instructions establish context; the collab system appends below)
  - (b) At the start of the file
  - (c) After a specific section the user indicates
- **Git tracking** — Default: tracked. If the user prefers not to track collab files in git, add `collab/` and `.collab-config` to `.gitignore`.

Wait for the user's choices before proceeding.

### Step 3: Create Files

Copy the template files from this repository into the target project. If the user chose a custom directory, substitute it for `collab` throughout.

1. Copy `.collab-config` to the project root. If the user chose a custom directory, update the `collab_dir=` value to match.

2. Copy the entire `collab/` directory recursively from the repository into the project root (e.g., `cp -r /path/to/ai-collab-memory/collab/ ./collab/`). This is a single operation — do NOT create files one by one.

3. If the user opted out of git tracking, add `collab/` and `.collab-config` to the project's `.gitignore`.

4. **After copying**, narrate to the user what was created — briefly explain each file's purpose:

   ```
   .collab-config                → system settings (directory path, thresholds)
   collab/.collab-memory-system  → version marker identifying this installation
   collab/methodology.md         → your operating instructions for the memory system
   collab/index.md               → episodic memory index — compact cue table (Tier 1, always in context)
   collab/notes.md               → episodic memory — detailed notes (Tier 2, searched on demand)
   collab/docs/.gitkeep          → directory for long-form reference documents (Tier 2)
   collab/world/index.md         → world model index — cue table to world knowledge (Tier 1)
   collab/world/context.md       → personal, project, and business context (Tier 1)
   collab/world/preferences.md   → user working preferences and communication style (Tier 1)
   collab/world/state.md         → current mutable state — work in progress, todos (Tier 1)
   collab/world/how-tos.md       → procedures for recurring tasks (Tier 2)
   collab/world/domain.md        → domain-specific knowledge and decisions (Tier 2)
   collab/world/factoids.md      → specific facts, numbers, references (Tier 2)
   ```

   If the repository was not cloned locally (e.g., files were read via web fetch), read each template file from the remote repository and create it locally.

### Step 4: Configure Instruction File

Insert the import block into the project's instruction file at the chosen placement (default: end of file). If no instruction file exists, create one (e.g., `CLAUDE.md`).

**Never overwrite existing content.** Insert the block at the chosen position, preserving everything else.

The import block (adjust `collab/` if a custom directory was chosen):

```markdown
<!-- collab-memory-system:start -->

## Collab Config
@collab/.collab-config

## Methodology
@collab/methodology.md

## World Model
@collab/world/context.md
@collab/world/preferences.md
@collab/world/state.md

## World Model Index
@collab/world/index.md

## Episodic Memory Index
@collab/index.md

<!-- collab-memory-system:end -->
```

**Note on import syntax:** The `@path` syntax is Claude Code-specific. Other AI platforms use their own import or file-inclusion mechanism. The heading structure (`##` grouping, `###`/`####` content) applies regardless of platform — it ensures files compose into a consistent hierarchy when loaded into context.

**If inserting at the end** of an existing file, add a blank line before `<!-- collab-memory-system:start -->` to visually separate the collab block from the user's existing content.

### Step 5: Platform-Specific Setup

#### Claude Code

Install the lifecycle hook and configure it in the project's settings.

1. **Copy the hook script:**

   ```
   .claude/hooks/collab-memory-hook.sh
   ```

   Copy from this repository's `hooks/claude-code/collab-memory-hook.sh`. Create the `.claude/hooks/` directory if it doesn't exist. Make the script executable.

2. **Configure hooks in `.claude/settings.json`:**

   If `.claude/settings.json` does not exist, create it with:

   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/collab-memory-hook.sh",
               "timeout": 5
             }
           ]
         }
       ],
       "UserPromptSubmit": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/collab-memory-hook.sh",
               "timeout": 5
             }
           ]
         }
       ]
     }
   }
   ```

   If `.claude/settings.json` already exists, **merge** the hook entries into the existing `hooks` object. Do not overwrite existing hooks — add the collab-memory entries alongside them. If there are existing hooks on `SessionStart` or `UserPromptSubmit`, add the collab-memory hook as an additional entry in the same event's array.

3. **Report overlapping hooks** — If the project already has hooks on `SessionStart` or `UserPromptSubmit` (whether at project, user, or organization level), inform the user. Read the collab-memory hook script to understand its specific functionality (timestamps, health checks, session/compaction recovery prompts), compare it against the existing hooks' behavior, and give the user a concrete recommendation about whether to keep both, merge them, or remove one.

   **Merge strategies for overlapping hooks:**
   - **Integrate into existing hook (default):** Merge the collab-memory functionality into the user's existing hook script. One approach: wrap the collab-memory logic in a conditional (e.g., `if [ "$COLLAB_ENABLED" = true ]`) so the user can toggle it. This avoids duplication and keeps everything in one script.
   - **Keep both:** Install the collab-memory hook alongside existing hooks. Both fire on the same events. Simple, but may produce duplicate output (e.g., two timestamps).
   - **Replace:** If the existing hook's functionality is a subset of the collab-memory hook, the user may prefer to replace it entirely.

   Discuss the options with the user and let them choose. If hooks exist at the user level rather than the project level, note this — the user may prefer to integrate the collab-memory hook into their user-level script rather than adding a separate project-level hook.

#### Other Platforms

For platforms other than Claude Code, skip hook installation. The methodology instructions in `collab/methodology.md` are self-contained — hooks enhance the experience (timestamps, health checks, session reminders) but are not required for the core system to function. The user can add platform-specific hooks later.

### Step 6: Initial World Population

Ask the user:

> "Would you like to provide some initial context? For example:
> - What is this project about and what is your role in it?
> - Are there things you are currently working on?
> - Do you have any preferences for how we collaborate (communication style, level of detail, etc.)?
>
> Anything else you'd like me to know? You can also skip this — the system will learn naturally as we collaborate."

**If the user responds with information:**
- Parse their free-form answer
- Distribute relevant content across the appropriate world files, in this order:
  1. Personal background, project description, business context, constraints, tech stack → `world/context.md` (frames everything else)
  2. Communication preferences, code style, working approach → `world/preferences.md`
  3. Domain knowledge, procedures, specific facts → Tier 2 files (`world/domain.md`, `world/how-tos.md`, `world/factoids.md`), with doc references where applicable
  4. Current work in progress, active tasks, open questions → `world/state.md` (last — depends on knowing what exists)
- Replace the HTML comment placeholders with the actual content, keeping the section headings
- Show the user what you wrote in each file

**If the user skips:** leave the template files as they are. The behavioral triggers in the methodology will populate these files organically during normal collaboration.

**Existing documentation:** If the project has existing documentation (design docs, analysis reports, reference material), discuss with the user whether project-specific docs should be moved to `collab/docs/`. This makes the collab directory self-contained and enables simple relative references (`docs/filename.md`). Non-project docs (shared across projects, owned by other teams) should stay in their original location and be referenced with absolute paths. After moving or identifying docs, add references to them in the relevant world model files (see the doc reference convention in `methodology.md` Section 4).

### Step 7: Verify Installation

Run through this checklist and report results to the user:

- [ ] `.collab-config` exists at project root
- [ ] `collab/.collab-memory-system` exists and contains a version string
- [ ] All 10 collab files exist (`methodology.md`, `index.md`, `notes.md`, and 7 world files)
- [ ] `collab/docs/` directory exists
- [ ] Instruction file contains the import block between `<!-- collab-memory-system:start -->` and `<!-- collab-memory-system:end -->` markers
- [ ] (Claude Code) Hook script exists at `.claude/hooks/collab-memory-hook.sh` and is executable
- [ ] (Claude Code) `.claude/settings.json` contains hook entries for `SessionStart` and `UserPromptSubmit`

If all checks pass, inform the user:

> "The collaboration memory system is installed. It will become active when you start a new session — the methodology, memory files, and hooks will load automatically at that point. The system will build up knowledge naturally as we collaborate."

If any checks fail, report which ones and ask the user how to proceed. For issues that cannot be resolved, the user can file an issue at https://github.com/visionscaper/ai-collab-memory/issues.

### Step 8: Migrate Existing Notes (if applicable)

If Step 1 identified an existing notes or journaling system, discuss migration with the user:

**Transition notice:** When migrating from an existing system, recommend adding a visible comment before the collab-memory-system import block in the instruction file:

```markdown
<!-- IMPORTANT: We are transitioning from the old memory system (above) to the collaboration memory system (below).
     The new system is authoritative where it covers a topic. Old content will be progressively migrated and removed. -->
```

This helps any AI session understand which system is authoritative during the migration period.

1. **Assess feasibility** — Describe what you found (file format, number of entries, structure). Discuss with the user whether migration makes sense: Are the notes still relevant? Is the format compatible? Would the project benefit from having this history in the episodic memory system? Migration is optional — the user may prefer to start fresh and keep old notes as a separate archive.

2. **Plan the migration** — If the user wants to migrate:
   - Determine how existing entries map to the collab system: which are episodic notes (`notes.md`), which are domain-specific logs (e.g., experiment logs as a domain extension), and which are project context that belongs in world model files. Discuss your findings with the user — they may have important insights about the structure or preferences about how things should be organised.
   - If an existing index or index-like structure exists (e.g., keyword summaries in an instruction file), assess its coverage — does it reference all notes, or are there gaps? Plan to create index entries for unreferenced notes as well.
   - **Before starting, list the kinds of world model topics that could be relevant** for this project (e.g., architecture decisions, technology constraints, domain knowledge, procedures, key facts). This primes your attention for recognising world model knowledge as you read each note.

3. **Migrate chronologically** — Work through the existing notes in chronological order. For each note:
   - Copy to `notes.md` (adjust to the note template format: `###` heading with `[DD-MM-YYYY]` date, `**With:**` field, `---` separator between notes). Copy related domain-specific entries (e.g., experiment logs) to their respective files.
   - Create an index entry in `index.md` — use any existing index or summary as reference material; write new entries from scratch where none exist. Follow the index writing guidelines in the methodology (concise contextualized facts, distinctive terms, retrieval cues).
   - Check if the note contains knowledge for the world model: new facts, procedures, domain knowledge, context, or preferences. Update the relevant world files when you find something. **Don't forget to update `world/index.md` when Tier 2 world files change.**
   - When building the world model during migration, populate context.md and preferences.md first (they frame all other knowledge), then Tier 2 files, then state.md.
   - For low-content notes, batching 2-4 at a time is acceptable. For notes with significant decisions or learnings, work one at a time to ensure careful world model review.

4. **Track progress** — For large note sets that may span multiple sessions, record migration progress in `world/state.md` (e.g., "Migration: 45/184 notes done"). This is Tier 1, so the next session sees it immediately and can continue where you left off.
