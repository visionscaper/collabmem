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

## Prerequisites

You need access to this repository's files to read the templates. The repository is public — read files directly from GitHub (e.g., via web fetch of raw file URLs). If direct reading is not possible on your platform, ask the user to clone the repository locally:

```
git clone https://github.com/visionscaper/ai-collab-memory.git
```

## Installation Steps

### Step 1: Assess Existing Setup

Before doing anything, examine the target project:

1. **Instruction file** — Check if the project has an instruction file (e.g., `CLAUDE.md`, `.cursorrules`, or equivalent). Read its contents. Note:
   - Does it already contain collab-memory-system markers (`<!-- collab-memory-system:start -->`)?  If yes, the system is already installed — inform the user and stop.
   - Does it contain instructions that contradict the methodology (e.g., "never write notes", "don't ask questions")?  Flag these for the user.

2. **Existing hooks** — Check if the project has lifecycle hooks configured (e.g., `.claude/settings.json` for Claude Code). Note any hooks on `SessionStart` or `UserPromptSubmit` events — these overlap with the collab system's hooks. See `hooks/claude-code/collab-memory-hook.sh` in this repository for the hooks that will be installed.

3. **Directory conflicts** — Check if `collab/` (or the chosen directory name) already exists at the project root. Check if `.collab-config` already exists.

4. **Report findings** — Tell the user what you found: instruction file status, existing hooks, any conflicts. If there are conflicts, ask how to proceed before continuing.

### Step 2: Confirm with User

Ask the user a single question:

> "I'll install the collaboration memory system with recommended defaults into `collab/` at the project root, with imports at the top of your instruction file. All files will be git-tracked and human-auditable. Shall I proceed with defaults, or would you prefer to review customization options first?"

**If the user chooses defaults:** proceed to Step 3.

**If the user wants to customize**, present these options:

- **Directory location** — Default `collab/` at project root. The directory must be in the project tree for git tracking. The user can choose a different name or location.
- **Import placement** — Where to insert the import block in the instruction file. Options:
  - (a) At the start of the file (default — the collab system is infrastructure that other instructions build on)
  - (b) At the end of the file
  - (c) After a specific section the user indicates

Wait for the user's choices before proceeding.

### Step 3: Create Files

Read each template file from this repository and create it in the target project. If the user chose a custom directory, substitute it for `collab` throughout.

1. Copy `.collab-config` to the project root. If the user chose a custom directory, update the `collab_dir=` value to match.

2. Create the entire `collab/` directory structure (including `collab/docs/.gitkeep` and `collab/.collab-memory-system`).

3. Narrate each file as you create it — briefly explain what the file is for. The full list:

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

### Step 4: Configure Instruction File

Insert the import block into the project's instruction file at the chosen placement (default: start of file). If no instruction file exists, create one (e.g., `CLAUDE.md`).

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

**If inserting at the start** of an existing file, add a blank line after `<!-- collab-memory-system:end -->` to visually separate the collab block from the user's existing content.

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

3. **Report overlapping hooks** — If the project already has hooks on `SessionStart` or `UserPromptSubmit`, inform the user. The collab-memory hook will run alongside existing hooks. If existing hooks provide similar functionality (timestamps, context reminders), suggest the user review whether they want to keep both or remove the older one.

#### Other Platforms

For platforms other than Claude Code, skip hook installation. The methodology instructions in `collab/methodology.md` are self-contained — hooks enhance the experience (timestamps, health checks, session reminders) but are not required for the core system to function. The user can add platform-specific hooks later.

### Step 6: Initial World Population

Ask the user:

> "Would you like to provide some initial context about yourself, your project, or how you prefer to work? I'll use this to populate your world model files. You can skip this — the files will be populated naturally as we collaborate."

**If the user responds with information:**
- Parse their free-form answer
- Distribute relevant content across the appropriate world files:
  - Personal background, project description, business context, constraints, tech stack → `world/context.md`
  - Communication preferences, code style, working approach → `world/preferences.md`
  - Current work in progress, active tasks, open questions → `world/state.md`
- Replace the HTML comment placeholders with the actual content, keeping the section headings
- Show the user what you wrote in each file

**If the user skips:** leave the template files as they are. The behavioral triggers in the methodology will populate these files organically during normal collaboration.

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
