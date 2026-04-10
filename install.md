# Collaboration Memory System — Installation

These instructions are for you, the AI assistant. Follow them step by step to install the collaboration memory system into the user's project. The system gives you long-term episodic and world model memory that survives across sessions and context compaction.

**What gets installed:**
- A collaboration directory (default `collab/`, user-configurable) with memory files (methodology, indexes, notes, world model)
- A `.collab-config` file at the project root
- Imports added to the project's instruction file (e.g., CLAUDE.md)
- Platform-specific lifecycle hooks (if supported)

**Repository structure reference:**
```
.collab-config              → code repo root
collab/                     → (solo: real directory | team: symlink to external location)
├── .collab-memory-system   (version marker)
├── methodology.md          (your operating instructions)
├── index.md                (episodic memory index — Tier 1)
├── notes.md                (episodic memory — Tier 2)
├── index-archive.md        (archived index entries — Tier 2)
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

**Note on solo vs team:** For **solo** installations, `collab/` is a real directory in the code repo. For **team** installations, `collab/` is a symlink pointing to an external shared-knowledge repo (e.g., `../shared-knowledge/collab/project-x/`). The solo/team choice is made in Step 2 and explained in the README's "Distributed Collaboration" section.

## Principles

These are hard rules. Follow them without exception.

1. **NEVER destroy or modify existing user content.** Do not overwrite, delete, or alter any existing files, instructions, or data without explicit user approval. All additions are clearly marked and placed alongside existing content.
2. **Flag conflicts, don't resolve them.** If you detect potential issues (existing instructions that contradict the methodology, duplicate hooks, conflicting file structures), report them to the user and ask how to proceed. Do not resolve conflicts unilaterally.
3. **Narrate every action.** Tell the user what you are doing at every step — what file you are creating, what content you are adding, what hook you are installing.
4. **Confirm before executing.** Describe what you will install, explain what each component is for, and ask for confirmation before making any changes.
5. **Suggest filing issues for unresolvable problems.** If you encounter a problem during installation that cannot be resolved without changes to the system itself (the methodology, templates, hooks, or installation procedure), suggest the user file an issue at https://github.com/visionscaper/collabmem/issues. Help draft the issue if the user wants.

## Prerequisites

You need local access to this repository's files to read the templates and copy them into the target project. If you are reading this file, you likely already have the repository cloned. If not, clone it first:

```
git clone https://github.com/visionscaper/collabmem.git /tmp/collabmem
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

3. **Directory conflicts** — Check if `collab/` already exists at the project root (as a directory or a symlink). Check if `.collab-config` already exists at the project root.

4. **Existing notes or journaling** — Check if there are instructions that indicate the project uses a notes or journaling system (e.g., instructions to write notes, maintain a journal, update an index, or log experiments). Look for referenced files like `notes.md`, `dev-notes.md`, `journal.md`, `experiment-logs.md`, or sections in the instruction file that serve as a history of past work. Also check whether the instruction file acts as an index (keyword-rich summaries pointing to detailed files). If the user mentions an existing system, investigate its structure.

5. **Report findings** — Tell the user what you found: instruction file status, existing hooks, existing notes/journals, any conflicts. If there are conflicts, ask how to proceed before continuing.

### Step 2: Solo or Team Use?

Before installing, ask the user:

> "Is this memory system for solo use, or will it be shared with a team or organisation? This choice matters because it determines where the memory lives:
>
> - **Solo** — The collab memory can live inside the project's code repository (default). Simple, everything in one place.
> - **Team** — The collab memory lives in a separate repository shared across the team. This avoids branch-divergence merge conflicts, keeps private project knowledge out of public code repos, and gives memory its own commit history separate from code churn. See 'Distributed Collaboration' in the README for the full rationale."

**If solo:** Default installation — `collab/` at project root, tracked in the code repo. Continue to Step 3.

**If team:** Ask:

> "Do you already have a shared-knowledge repository for this team?"

- **Yes** — Ask the user for its location (local path). Explain that the typical team pattern is `<shared-knowledge-repo>/collab/<project-name>/` — confirm with the user where the new project's memory directory should go.
- **No** — Explain the two patterns (paraphrase from the README "Distributed Collaboration" section): single shared-knowledge repo containing all projects, or per-project memory repos. Recommend the single shared-knowledge repo as the default unless the user has access-control reasons for per-project repos. Offer to help create it:
  - If `gh` is available, offer to create a new GitHub repo (e.g., `gh repo create <org>/shared-knowledge --private`) and clone it locally. Confirm the org/name with the user before creating.
  - Otherwise, give the user manual instructions to create the repo and clone it. Wait for the user to confirm it's ready.
  - Once the shared repo exists, the new project's memory will live at `<shared-repo>/collab/<project-name>/`.

**How team installations work:** The collab directory lives in the external shared-knowledge repo. In the code repo, a symlink named `collab` points to the external location. This keeps `.collab-config`, the import block, and all `@collab/...` paths identical between solo and team installations — the symlink handles the redirection transparently. The symlink is git-ignored (each dev creates their own after cloning the code repo).

Once the shared repo is in place and the target path is confirmed, continue to Step 3.

### Step 3: Confirm Installation Details

Once the solo/team decision is made, summarise for the user what you found in Step 1 (instruction file, existing hooks, conflicts) and the solo/team choice from Step 2, then describe what you are about to install (directory location, import placement, hooks). Then ask:

> "Shall I proceed with recommended defaults, or would you prefer to review customization options first?"

**If the user chooses defaults:** proceed to Step 4.

**If the user wants to customize**, present these options:

- **Directory location** — For solo use: default `collab/` at project root, customisable name/location. For team use: the shared-knowledge path was already chosen in Step 2; the symlink in the code repo is named `collab` (not customisable — all team members must use the same symlink name for the `@collab/...` import paths in the shared instruction file to work consistently across their machines).
- **Import placement** — Where to insert the import block in the instruction file. Options:
  - (a) At the end of the file (default — existing project instructions establish context; the collab system appends below)
  - (b) At the start of the file
  - (c) After a specific section the user indicates
- **Git tracking** — For **solo**: default tracked (add nothing to `.gitignore`). If the user prefers not to track, add `collab/` and `.collab-config` to `.gitignore`. For **team**: the `collab` symlink must always be git-ignored (each dev creates their own). Ask the user about `.collab-config`: it can be committed (simpler — same on every machine since it only contains a relative path) or git-ignored (keeps the code repo free of any memory system traces, useful for public repos or when teams prefer full separation). If git-ignored, each dev creates `.collab-config` manually after cloning — the final installation note (see Step 9) will include the full `.collab-config` contents for easy reproduction.

Wait for the user's choices before proceeding.

### Step 4: Create Files

Copy the template files and set up the collab directory (and symlink for team installations).

1. **Copy `.collab-config` from `/path/to/collabmem/.collab-config` to the code repo root.** Set the `collab_dir=` value to the directory name chosen in Step 3 (defaults to `collab`). For team installations, this is the symlink name in the code repo (always relative) — the symlink handles redirection to the external location.

2. **Copy the `collab/` directory contents to the target location.** Use a single recursive copy — do NOT create files one by one.
   - For **solo**: `cp -r /path/to/collabmem/collab ./collab`
   - For **team**: first ensure the parent directory exists (`mkdir -p /path/to/shared-knowledge/collab`), then copy: `cp -r /path/to/collabmem/collab /path/to/shared-knowledge/collab/<project-name>`

3. **For team installations, create the symlink in the code repo root:**
   ```bash
   ln -s /path/to/shared-knowledge/collab/<project-name> collab
   ```
   Use a relative path if the shared-knowledge repo is a sibling of the code repo (e.g., `../shared-knowledge/collab/<project-name>`) — this makes the symlink portable across machines that follow the same layout convention. Otherwise use an absolute path.

4. **Apply git tracking choices:**
   - For **solo** without git tracking: add `collab/` and `.collab-config` to the code repo's `.gitignore`. The trailing slash matches the directory name anywhere in the tree.
   - For **team**: always add `/collab` to the code repo's `.gitignore` (it's a symlink at the code repo root, each dev creates their own). The leading slash anchors the entry to the repo root specifically. If the user chose to git-ignore `.collab-config`, also add it to `.gitignore`.

5. **After copying**, narrate to the user what was created — briefly explain each file's purpose. Paths below use `<collab>` to denote the collab directory (actual location depends on solo/team choice; `.collab-config` is always at the code repo root):

   ```
   .collab-config                → system settings (directory path, thresholds), always at code repo root
   <collab>/.collab-memory-system  → version marker identifying this installation
   <collab>/methodology.md         → your operating instructions for the memory system
   <collab>/index.md               → episodic memory index — compact cue table (Tier 1, always in context)
   <collab>/notes.md               → episodic memory — detailed notes (Tier 2, searched on demand)
   <collab>/index-archive.md       → archived index entries after consolidation (Tier 2)
   <collab>/docs/.gitkeep          → directory for long-form reference documents (Tier 2)
   <collab>/world/index.md         → world model index — cue table to world knowledge (Tier 1)
   <collab>/world/context.md       → personal, project, and business context (Tier 1)
   <collab>/world/preferences.md   → user working preferences and communication style (Tier 1)
   <collab>/world/state.md         → current mutable state — work in progress, todos (Tier 1)
   <collab>/world/how-tos.md       → procedures for recurring tasks (Tier 2)
   <collab>/world/domain.md        → domain-specific knowledge and decisions (Tier 2)
   <collab>/world/factoids.md      → specific facts, numbers, references (Tier 2)
   ```

   For team installations, also narrate: "Created symlink `collab` → `<target path>` in the code repo root."

   If the repository was not cloned locally (e.g., files were read via web fetch), read each template file from the remote repository and create it locally.

### Step 5: Configure Instruction File

Insert the import block into the project's instruction file at the chosen placement (default: end of file). If no instruction file exists, create one (e.g., `CLAUDE.md`).

**Never overwrite existing content.** Insert the block at the chosen position, preserving everything else.

**Before inserting, check the following:**

- **Import path resolution — CRITICAL:** Import paths (e.g., `@collab/methodology.md`) resolve **relative to the instruction file where they appear**, not relative to the project root. If the instruction file is at the project root (e.g., `./CLAUDE.md`), then `@collab/...` correctly reaches `./collab/...`. If the instruction file is in a subdirectory (e.g., `.claude/CLAUDE.md`), then `@collab/...` would look for `.claude/collab/...` which does not exist — **the import silently fails and no content is loaded**. Adjust the paths based on the instruction file's location:
  - Instruction file at project root (`./CLAUDE.md`): use `@collab/...` as in the template below
  - Instruction file in `.claude/` (`.claude/CLAUDE.md`): use `@../collab/...` — the `../` navigates up from `.claude/` to the project root where `collab/` lives (as a real directory or symlink)
  - Instruction file in another location of the repo: adjust the relative path accordingly so it navigates from the instruction file's directory to the `collab/` directory
  - **External collab directory (outside the repo root):** Relative paths cannot reach outside the repository root — this is a security restriction. Use absolute paths instead (e.g., `@~/workspace/shared-knowledge/collab/project-x/methodology.md`). Note that absolute paths are not portable across machines or team members — each developer would need their own instruction file (git-ignored) with their local absolute paths. The symlink approach (see Step 2) avoids this by keeping the collab directory reachable via a relative path within the repo.
- **Directory name:** If the user chose a custom directory name in Step 3, replace `collab/` throughout the template below with the chosen name.
- **Import syntax:** The `@path` syntax in the template below is Claude Code-specific. For other AI platforms, ask the user how their platform handles file imports or file-inclusion, and adapt the template accordingly. The heading structure (`##` grouping) applies regardless of platform — it ensures files compose into a consistent hierarchy when loaded into context.
- **Blank line:** If inserting at the end of an existing file, add a blank line before `<!-- collab-memory-system:start -->` to visually separate the collab block from the user's existing content.

The import block template (paths shown for instruction file at project root — adjust as described above):

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

### Step 6: Platform-Specific Setup

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

### Step 7: Initial World Population

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

**If the user skips:** leave the template files as they are. The word cues and conceptual triggers in the methodology will help populate these files organically during normal collaboration.

**Existing documentation:** If the project has existing documentation (design docs, analysis reports, reference material), discuss with the user whether project-specific docs should be moved to `collab/docs/`. This makes the collab directory self-contained and enables simple relative references (`docs/filename.md`). Non-project docs (shared across projects, owned by other teams) should stay in their original location and be referenced with absolute paths. After moving or identifying docs, add references to them in the relevant world model files (see the doc reference convention in the World Model Protocol in `methodology.md`).

### Step 8: Verify Installation

Run through this checklist and report results to the user. Paths use `<collab>` for the collab directory (actual location depends on solo/team choice):

- [ ] `.collab-config` exists at code repo root
- [ ] For team installations: `collab` symlink exists at code repo root and resolves to the external target
- [ ] `<collab>/.collab-memory-system` exists and contains a version string
- [ ] All 11 collab files exist (`methodology.md`, `index.md`, `index-archive.md`, `notes.md`, and 7 world files)
- [ ] `<collab>/docs/` directory exists
- [ ] Instruction file contains the import block between `<!-- collab-memory-system:start -->` and `<!-- collab-memory-system:end -->` markers
- [ ] (Claude Code) Hook script exists at `.claude/hooks/collab-memory-hook.sh` and is executable
- [ ] (Claude Code) `.claude/settings.json` contains hook entries for `SessionStart` and `UserPromptSubmit`
- [ ] `.gitignore` entries correct: solo without tracking → `collab/` + `.collab-config`; team → `/collab` + (optionally `.collab-config`)

If any checks fail, report which ones and ask the user how to proceed. For issues that cannot be resolved, the user can file an issue at https://github.com/visionscaper/collabmem/issues.

Continue to Step 9 if all checks pass.

### Step 9: Record Installation Note

Write the first episodic note documenting the installation. This serves three purposes: it creates an audit trail, demonstrates the memory system's note-writing behaviour, and provides a diagnostic anchor to verify the system works in a new session.

**First, read `<collab>/methodology.md` if you haven't already.** It defines the note template, the amendment protocol, the index entry conventions ("concise contextualized facts"), and the append-only rule for episodic memory. The templates below match the methodology conventions at the time of writing, but the methodology is the source of truth.

Append a note to `<collab>/notes.md` (append to the bottom — episodic memory is append-only; use today's date). The template below shows the minimum to capture; expand any section with more detail as relevant — this is a real note, not a form:

```
---

### [DD-MM-YYYY] Collaboration Memory System Installed

**With:** @<username> (use `git config user.name` by default; if unclear or empty, ask the user)

**Context:** Initial installation of the collabmem system on this project. Describe briefly why the user wanted the memory system and any relevant project/team context.

**What We Did:**
- Installed collabmem version <vX.X> (from `<collab>/.collab-memory-system`)
- Installation type: <solo | team>
- Collab directory location: <actual path, e.g. `./collab/` or `/path/to/shared-knowledge/collab/project-x/`>
- For team installations: symlink `collab` → `<target>` created in code repo root
- Import placement: <at end of file | at start | after specific section> in <instruction file name>
- Git tracking: `.collab-config` <committed | git-ignored>; collab directory <tracked | git-ignored | external repo>
- Hooks installed: <yes (Claude Code: SessionStart, UserPromptSubmit) | skipped (other platform)>
- Hook overlap handling: <none | integrated | kept both | replaced>
- Initial world population: <done | skipped>. If done, summarise what kinds of context the user provided and which world files were populated.
- Anything else relevant: issues encountered and how they were resolved, user decisions made during install, deviations from defaults.

**`.collab-config` contents:**
```
<paste actual file contents here>
```

**Key Learnings:**
- Memory system is now active and will load automatically on new sessions.
- <For team:> Other team members who clone this code repo later will need to create their own `collab` symlink.
- Add any other observations: what worked smoothly, what caused friction, what the user should know going forward.

**Related:** `collab/methodology.md`, `collab/.collab-memory-system`
```

Also add the corresponding index entry to `<collab>/index.md`:

```
| DD-MM-YYYY | @<username> | Collaboration Memory System Installed | Initial collabmem installation: <solo/team>, hooks, world population status. First episodic note and index entry. | installation, setup, v<X.X>, <solo/team> |
```

**Final message to the user** (if Step 1 identified an existing notes/journaling system, do not yet declare the installation complete — continue to Step 10 first, then combine this message with the migration outcome):

> "The collaboration memory system is installed and a first note has been written. It will become active in a new session — the methodology, memory files, and hooks will load automatically. The system will build up knowledge naturally as we collaborate.
>
> **To verify it's working:** Start a new session and ask one of:
> - 'What kinds of AI collab memory do you have and how do they work?' — tests that the methodology is loaded.
> - 'What do you know about this project?' — tests that the world model is loaded (if you did world population).
> - 'What is the last thing we did?' — tests that the episodic index is loaded. The AI should mention the installation note."

**For team installations, include these additional instructions in the final message:**

> "Your symlink is already set up. For any other team member who clones this code repo later, they will need to create their own `collab` symlink after cloning. Commands:
>
> **macOS/Linux:**
> ```bash
> ln -s <relative or absolute path to shared-knowledge/collab/project-name> collab
> ```
>
> **Windows (PowerShell, requires developer mode or admin):**
> ```powershell
> New-Item -ItemType SymbolicLink -Path collab -Target <path to shared-knowledge/collab/project-name>
> ```
>
> **Windows (cmd, requires admin):**
> ```cmd
> mklink /D collab <path to shared-knowledge\collab\project-name>
> ```

**If `.collab-config` is git-ignored, also include its contents in the final message** so each dev can easily reproduce it:

> "Since `.collab-config` is git-ignored, each dev also needs to create it in the code repo root. Contents:
> ```
> <paste actual .collab-config contents here>
> ```"

### Step 10: Migrate Existing Notes (if applicable)

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
   - **Before starting, list the kinds of world model topics that could be relevant** for this project (e.g., architecture decisions, technology constraints, domain knowledge, procedures, key facts). This primes your attention for recognising world model knowledge during migration.

3. **Migrate notes and index** — Apply mechanical format transformations to migrate notes and index entries in bulk:
   - Copy notes to `notes.md`, adjusting to the note template format: `###` heading with `[DD-MM-YYYY]` date, `**With:**` field, `---` separator between notes. Use automated transformations (sed, find-replace) where possible — format differences between systems are typically small and mechanical (field renames, column reorder, heading format).
   - Copy or transform index entries to `index.md` — adjust column order to match the index format (`Date | Who | Title | Summary | Keywords`). If no index exists, create entries from the notes following the index writing guidelines in the methodology.
   - Copy related domain-specific entries (e.g., experiment logs) to their respective files. Copy reference docs to `collab/docs/`.
   - Notes are historical records. File paths and references within notes should remain as they were at time of writing — they were correct in their original context. Only update references to files that are physically moved as part of the migration itself (e.g., docs relocated from the old system to `collab/docs/`).

4. **Extract world model knowledge** — Read through the migrated notes as a corpus (or in batches for large note sets), identify recurring themes and topics, and populate world model files by topic rather than by note:
   - Populate context.md and preferences.md first (they frame all other knowledge), then Tier 2 files, then state.md.
   - Check for: domain knowledge, architecture decisions, procedures, facts, user context, and preferences.
   - **Don't forget to update `world/index.md` when Tier 2 world files change.**

5. **Track progress** — For large note sets that may span multiple sessions, record migration progress in `world/state.md` (e.g., "Migration: 45/184 notes done"). This is Tier 1, so the next session sees it immediately and can continue where you left off.

6. **Write a migration note when complete** — Once migration finishes (or at the end of each migration session if multi-session), append an episodic note to `<collab>/notes.md` capturing what was migrated, any decisions made, issues encountered, and learnings. This creates a historical record of the migration alongside the migrated content. Follow the note template from the Notes Protocol in `methodology.md`; include the corresponding index entry in `<collab>/index.md`.
