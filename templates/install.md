# Collaboration Memory System — Installation

These instructions are for you, the AI assistant. Follow them step by step to install the collaboration memory system into the user's project. The system gives you long-term episodic and world model memory that survives across sessions and context compaction.

{{user_friendliness}}

### Additional rules during installation

**Describe every step you perform.**

Say conceptually what you created, did or changed, what it is for, and what the result is. A list of commands or file paths is not a description.

## What Gets Installed

- A collaboration directory (default `collab/`, user-configurable) with memory files (methodology, indexes, notes, world model)
- A `.collab-config` file at the project root
- Imports added to the project's instruction file (e.g., CLAUDE.md)
- Platform-specific lifecycle hooks (if supported)

### Repository structure reference

```
.collab-config              → project root
collab/                     → (solo: real directory | team: symlink to external location)
├── .collab-memory-system   (version marker)
├── methodology.md          (your operating instructions)
├── support.md              (starmem support-ask procedure)
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

## The Three Setups

collabmem can be set up in three ways. The choice is made in Step 2, and `setup-options.md` describes each in detail — read it before you start.

- **Solo** — the memory lives inside the code repository, as a real `collab/` directory.
- **Standalone memory project** — there is no code repository; the memory repository *is* the project, and `collab/` is a real directory inside it.
- **Distributed** — the memory lives in a separate shared-knowledge repository; the code repository reaches it through a symlink named `collab`.

**Terminology in the steps below.** The installation steps distinguish only two mechanical cases. **Solo** means `collab/` is a real, tracked directory; this covers both the solo setup and the standalone memory project, which install identically. **Team** means `collab/` is a symlink into the shared-knowledge repository; this is the distributed setup.

**Project root.** Throughout this document, "project root" means the directory the AI session is rooted in. For the solo and distributed setups that is the root of the code repository. For a standalone memory project it is the memory project's own directory: the repository root when the project has its own repository, or `projects/<name>/` when it lives inside a shared-knowledge repository that holds several memory projects. In the distributed setup it never means the separate shared-knowledge repository.

**Memory-system traces.** The files collabmem puts in the project *besides* the memory itself: `.collab-config` at the project root, the import block in the instruction file, and `.claude/` with the hook script and its `settings.json` entries. In a distributed setup these are the only collabmem files in the code repository, and the user chooses in Step 3 whether they are committed or git-ignored.

## Hard Rules During Installation

These are hard rules to adhere to during the installation procedure. They are about what you do, and above all about what you must not do. Follow them without exception.

**1. Never destroy or change what the user already has.**

Do not overwrite, delete or alter existing files, instructions or data without the user's explicit approval. Whatever you add is clearly marked and placed next to the existing content.

**2. Report conflicts, do not resolve them yourself.**

Examples of a conflict: existing instructions that contradict the methodology, duplicate hooks, a file structure that is in the way. Tell the user what you found and ask how to proceed.

**3. Change nothing before the user has agreed.**

First describe what you will install and what each part is for. Then ask for the go-ahead, and wait for it.

**4. Suggest filing an issue when a problem cannot be solved without changing collabmem itself.**

That is the case when the methodology, the templates, the hooks or these instructions would have to change. Point the user to https://github.com/visionscaper/collabmem/issues and offer to help draft the issue.

## Prerequisites

You need local access to this repository's files to read the templates and copy them into the target project. If you are reading this file, you likely already have the repository cloned. If not, clone it first:

```
git clone https://github.com/visionscaper/collabmem.git /tmp/collabmem
```

## Installation Steps

### 1 - Finding out what the project has already

Before you change anything, look at what is there. Four checks, then tell the user.

#### 1.1 - Is collabmem installed here already?

Look for an instruction file for the AI, such as `CLAUDE.md`, and read it.

If it contains the collabmem markers (`<!-- collab-memory-system:start -->`), collabmem is installed. Tell the user and stop.

**One case looks the same but is unfinished: a teammate's fresh clone.** The markers are there, but there is no `collab` symlink or directory at the project root. This is a clone of a distributed install whose memory-system traces were committed. Nothing needs installing. Two steps on this machine are missing:

1. Create the `collab` symlink to the project's directory in the shared-knowledge repository. Ask the user where their clone of that repository is. If they have none yet, they need its location from a teammate, and clone it next to the code repository.
2. Run the load check described under "Verifying the installation". It will most likely need the approval for external imports; Issue 1 of the troubleshooting guide covers that.

Then stop.

Also note instructions that contradict collabmem, such as "never write notes".

#### 1.2 - Hooks and other collabmem installs that could clash

- **A user-level collabmem install.** Check `~/.claude/CLAUDE.md` for the collabmem markers, and `~/.claude/settings.json` for a `collab-memory-` hook. A user-level install loads in every project, so installing here as well would make a duplicate. Installing next to it is not an option. Offer to remove the user-level install: its block and its hook only, never the memory it points at.
- **Project-level hooks.** Check `.claude/settings.json` for hook definitions.
- **Hooks that are running already.** Their output shows up in your own context, as text injected at the start of the session or with each user message. They can come from settings you cannot see in the project.

Note every hook on the `SessionStart` or `UserPromptSubmit` event. collabmem's hook uses the same two events.

#### 1.3 - Names that are taken

Check whether `collab/` or `.collab-config` exists already at the project root.

#### 1.4 - An existing notes system

Check whether the project already keeps notes or a journal for the AI: instructions to write notes, or files such as `notes.md` or `journal.md`. The instruction file itself can be one, when it holds summaries that point to detailed files. Such a system can be migrated later.

#### 1.5 - Telling the user what you found

Tell the user what you found in each of the four checks, and what it means for the installation. When something is in the way, ask how to proceed.

### 2 - Choosing the setup that fits the user

collabmem can be set up in three ways. Ask the user which one fits, with this text:

> "How will this memory be used? Three options:
>
> - **Distributed** — for teams building one shared memory, for working from several machines, and for keeping private memory out of a public code repository. The memory lives in a separate shared-knowledge repository that this code repository links to.
> - **Standalone memory project** — for when there is no code at all: an organisation's memory, a research or business project, a non-technical working memory. This repository *is* the project, and the memory lives inside it.
> - **Solo, memory inside the code repository** — only for a private repository used by you alone, committing on the main branch. Everything in one place, but discouraged as soon as branches are involved: memory committed on a branch is invisible elsewhere until it merges."

Then continue with the part below that matches the user's choice.

**Standalone memory project**

A git repository with a private remote is required. The remote is the memory's backup, and it makes sharing the memory later a matter of cloning.

If the folder is not part of a repository already, run `git init` and offer to create a private remote, before you create any files.

**Solo**

Nothing more to settle here.

**Distributed**

The memory will live in a shared-knowledge repository, at `<shared-knowledge-repo>/projects/<project-name>/collab/`. Settle two things with the user.

1. **The shared-knowledge repository.** Ask whether the team already has one.

   - If yes: ask where its local clone is.
   - If no: explain the two ways to organise it, and recommend the first.
     - One shared-knowledge repository for all the team's memory projects.
     - One shared-knowledge repository per memory project, for when projects need separate access control.

     Then offer to create it: with `gh repo create <org>/shared-knowledge --private` when the `gh` tool is available, otherwise by giving the user the steps.

2. **The project name.** Propose one, for example the name of the code repository, and ask the user to confirm it.

### 3 - Agreeing on what will be installed

Before you create or change anything, the user must know what will be installed, and agree to it.

**First, in a distributed setup: one choice that is always the user's.**

Ask whether the memory-system traces should be committed to the code repository, or git-ignored. Only the user knows whether the code repository is public, and what the team prefers.

- **Committed** is the default for a private repository the whole team works on. A teammate who clones the code repository gets a working install after two steps on their own machine: creating the symlink, and approving external imports once. Nothing in these files is machine-specific.
- **Git-ignored** fits a public repository, or a team that prefers to keep collabmem out of the code repository. Each developer then keeps their own copies.

Files that exist already and are tracked, such as an existing `CLAUDE.md`, stay tracked: only new files can be git-ignored. Say so when it applies.

**Then, in every setup: describe, name the defaults, and ask.**

Tell the user what you are about to install and where: the memory directory, the collabmem block in the instruction file, and the hooks. In a distributed setup also the symlink, and what goes into `.gitignore`.

Name every default, and say that each can be changed. Without that the user cannot decide whether they want anything different. Then ask whether to proceed.

The defaults, and what they can be changed to:

- **The name of the memory directory.** `collab` by default. In a distributed setup it cannot be changed: the symlink must have the same name on every teammate's machine.
- **Where the collabmem block goes in the instruction file.** At the end by default, so the project's own instructions come first. It can also go at the start, or after a section the user names.
- **In a solo setup: whether the memory is tracked in git.** Tracked by default. Untracked means adding `collab/` and `.collab-config` to `.gitignore`.

### 4 - Creating the memory directory and the config file

`<collabmem>` below is the folder where you cloned collabmem.

**The config file.** Copy `<collabmem>/.collab-config` to the project root. Set `collab_dir=` to the name of the memory directory: `collab`, unless the user chose another name.

**The memory directory.** Copy it in one recursive copy, not file by file.

- Solo and standalone:

  ```bash
  cp -r <collabmem>/collab ./collab
  ```

- Distributed:

  ```bash
  mkdir -p <shared-knowledge-repo>/projects/<project-name>
  cp -r <collabmem>/collab <shared-knowledge-repo>/projects/<project-name>/collab
  ```

**In a distributed setup: the symlink.** In the project root:

```bash
ln -s <shared-knowledge-repo>/projects/<project-name>/collab collab
```

Use a relative path when the shared-knowledge repository sits next to the code repository, for example `../shared-knowledge/projects/<project-name>/collab`. The symlink then also works on a teammate's machine with the same layout. Otherwise use an absolute path.

**The `.gitignore` entries.**

- Distributed: always add `/collab`. The symlink is never committed: committed symlinks do not survive on Windows, and every developer creates their own. If the user chose to git-ignore the memory-system traces, also add `.collab-config`, and whichever of `CLAUDE.md` and `.claude/` are new.
- Solo, when the user chose not to track the memory: add `collab/` and `.collab-config`.

**Tell the user what now exists.** In a few sentences, not as a file listing. The memory directory and where it is. That it holds two kinds of memory: notes on what happened and why, and a world model, the current understanding of the project and the user. And the config file. In a distributed setup also the symlink.

### 5 - Adding the collabmem block to the instruction file

The block below makes the AI load the memory at the start of every session. It goes into the project's instruction file for the AI, such as `CLAUDE.md`. If there is none, create `CLAUDE.md`.

#### 5.1 - Where the block goes

Always in the instruction file of the project the session is rooted in: `./CLAUDE.md` or `.claude/CLAUDE.md`. Never in a user-level file such as `~/.claude/CLAUDE.md`. That file loads in every session on the machine, so one project's memory would load everywhere.

Within the file: at the end, unless the user chose another place.

#### 5.2 - The import paths depend on where the instruction file is

The lines starting with `@` are imports. They are resolved relative to the instruction file, not to the project root. A wrong path fails silently: nothing loads, and nothing warns you.

| Instruction file | Memory files | Config file |
|---|---|---|
| `./CLAUDE.md` | `@collab/...` | `@.collab-config` |
| `.claude/CLAUDE.md` | `@../collab/...` | `@../.collab-config` |

The config file is at the project root, not inside the memory directory. Its line is the only one that does not go through `collab/`.

The `@` syntax is specific to Claude Code. On another platform, ask the user how it includes files, and adapt the lines.

#### 5.3 - Three more things to adjust

- **The directory name.** If the user chose another name than `collab`, use it throughout the block.
- **The version stamp.** Replace `<version>` in the block's first line with the value in `<collabmem>/collab/.collab-memory-system`. Keep it as plain text. It tells a later upgrade whether this copy of the block is current.
- **The troubleshooting-guide path** in the load-check section, `collab/docs/troubleshoot.md`. It is not an import: the AI opens it later with its file tools, which start from the project root. So do not adjust it along with the import paths. Change it only for another directory name.

#### 5.4 - The load check in the block is not for this session

The block contains a load check. It is meant for sessions that start with the block in place. This session never loaded the memory and cannot. Do not run the check on yourself, and do not report its failure banner. The load check of a fresh session comes later, under "Verifying the installation".

#### 5.5 - The block

The paths are shown for an instruction file at the project root.

```markdown
<!-- collab-memory-system:start -->
collabmem instruction block, checked and updated up to: <version>

## Collab Config
@.collab-config

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

## COLLABMEM-LOAD-CHECK

At this point the collabmem memory system should be loaded. This section
describes how to verify that this is true, and what to do when it is not.

Each import statement above should have caused the contents of the imported
file to be placed into your context window (typically as separate labelled
blocks — the exact layout depends on the harness). To verify this, confirm
that two marker lines are present in your context window, inside the imported
file content: the text `COLLABMEM-MARKER-` joined with `METHODOLOGY` (from
methodology.md), and `COLLABMEM-MARKER-` joined with `CONTEXT` (from the world
model context.md). "Joined" means the single unbroken token formed by
concatenating the two parts with no space; the prefix alone — which appears in
this section — does not count.

Verify by inspecting what is already in your context window — do NOT use tools
to search for the markers. Marker text found in tool results, your own earlier
messages, or a compaction summary does not count.

If this instruction file imports `context.md` files from more than one
collabmem install — for example an organisation-level memory imported
alongside this project's own — each imported `context.md` carries its own copy
of the context marker line. In that case confirm one marker occurrence per
imported file, not just one occurrence overall; a missing occurrence means
that install's import failed. The same applies to any other imported file
carrying a marker line.

If this COLLABMEM-LOAD-CHECK section, the collabmem methodology marker
(`COLLABMEM-MARKER-` joined with `METHODOLOGY`), or the collabmem hook output
appears more than once in your context, then more than one collabmem install
is active over the same memory. Occurrences that appear only in a compaction
summary do not count. Tell the user before doing anything else, in plain
language: the memory system is active twice in this session, and this needs
resolving — usually by removing the extra copy. Ask whether they want to
clean this up. If they agree, discuss with them which copy to remove —
recommend keeping the project-level one — and only then consult the
"duplicate installs" note in the troubleshooting guide (see below) and remove
anything. Technical detail only if asked. Do not proceed as if this were a
single install. The section count is the most reliable of the three signals:
instruction files are never merged, so this section appears once per active
install, whereas the harness may merge two imports of the same memory file
into one. A second occurrence of any of the three always means a second
install — for example a user-level install left in place next to a
project-level one.

Perform this check once, in your first response after a session start or a
compaction (on platforms with a session-start hook, when the hook asks). Do
not repeat it on later turns. If you are about to perform any memory operation
and you notice that neither banner line has appeared in the session so far,
the check has not run yet — perform it now.

If either marker is absent, the memory system did NOT load properly. In that
case: tell the user before doing anything else, and do not read the memory
files as a substitute before the user has been told — a silently-patched
session hides the problem and gives the user a degraded experience without
them knowing why. Start your report with this exact line:
====== COLLABMEM MEMORY SYSTEM FAILED TO LOAD ======
Explain in plain language (no jargon about markers, imports, symlinks, or
harness config) — say the memory files did not load, not the internal reason.
Offer technical detail only if the user asks. After informing the user, offer
to help resolve it. When the user agrees,
start by consulting the troubleshooting guide:

- Local (Claude Code installs): `collab/docs/troubleshoot.md`
- Otherwise, or if the local file is unreachable or you can't find it, the
  canonical guide:
  https://raw.githubusercontent.com/visionscaper/collabmem/refs/heads/main/clients/claude-code/troubleshoot.md

When both markers are present, the memory system loaded correctly — report
this to the user, starting your message with this exact line:
====== COLLABMEM MEMORY SYSTEM LOADED SUCCESSFULLY ======

<!-- collab-memory-system:end -->
```

### 6 - Installing the session hook (Claude Code)

The hook is a small script that Claude Code runs at the start of every session and with every user message. At the start of a session it tells the AI to check that the memory loaded. With every message it gives the AI the date and time. Use those words, or similar, when you tell the user about it.

#### 6.1 - The hook script

Copy `<collabmem>/clients/claude-code/hooks/collab-memory-hook.sh` to `.claude/hooks/collab-memory-hook.sh` in the project, and make it executable.

#### 6.2 - Telling Claude Code to run it

The entries below go into `.claude/settings.json`. If the file exists already, add them to its `hooks` object.

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

#### 6.3 - When the project has hooks on the same events already

You found those in check 1.2. One rule decides what to do: the collabmem hook must stay its own, unchanged file. Its version stamp and the upgrade check depend on that.

Compare what the existing hook does with what the collabmem hook does, and recommend one of these to the user:

- **Keep both.** The default. `settings.json` accepts several commands per event, so both run.
- **Let the existing hook call ours.** For a user who wants a single entry in `settings.json`: their script runs `"$CLAUDE_PROJECT_DIR"/.claude/hooks/collab-memory-hook.sh`.
- **Replace the existing hook,** when it does nothing the collabmem hook does not do.

Never copy the collabmem hook's content into the user's script.

A hook at the user level simply keeps running next to ours. Keep the collabmem hook at the project level: at the user level it would run in every project on the machine.

#### 6.4 - A local copy of the troubleshooting guide

```bash
cp <collabmem>/clients/claude-code/troubleshoot.md <collab>/docs/troubleshoot.md
```

The load check points to this copy when loading fails.

#### 6.5 - The hook starts running in this session

From now on the hook's output appears in your own context, with every user message. It will tell you to run the load check. That is the hook you just installed, working as intended. Its instruction is not for this session: as said under 5.4, this session never loaded the memory.

#### 6.6 - Other platforms

Skip this step. The memory system works without hooks; they add the load check at session start and the date and time.

### Step 7: Initial World Population

Ask the user:

> "Would you like to provide some initial context? For example:
> - What is this project about and what is your role in it?
> - Are there things you are currently working on?
> - Do you have any preferences for how we collaborate (communication style, level of detail, etc.)?
>
> Anything else you'd like me to know? You can also skip this — the system will learn naturally as we collaborate."

For a **standalone memory project** there is no codebase to anchor these questions, so ask about the person and the purpose instead:

> "To give this memory a good start, could you tell me a bit about:
> - yourself — who you are and what you do or work on?
> - what you want to use this long-term memory for?
> - the project, study, or business it is about — anything you'd like me to know from the start?
> - how you like to collaborate (communication style, level of detail)?
>
> You can also skip this — the memory will grow as we work together."

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

- [ ] `.collab-config` exists at project root
- [ ] For team installations: `collab` symlink exists at project root and resolves to the external target
- [ ] `<collab>/.collab-memory-system` exists and contains a version string
- [ ] All 12 collab files exist (`methodology.md`, `support.md`, `index.md`, `index-archive.md`, `notes.md`, and 7 world files)
- [ ] `<collab>/docs/` directory exists
- [ ] Instruction file contains the import block between `<!-- collab-memory-system:start -->` and `<!-- collab-memory-system:end -->` markers, including the `COLLABMEM-LOAD-CHECK` section
- [ ] The block's first line is the version stamp (`collabmem instruction block, checked and updated up to: <version>`) with `<version>` replaced by the installed version, and the hook's header stamp (`collabmem hook, checked and updated up to:`) shows the same version — all three (block, hook, `<collab>/.collab-memory-system`) agree. On platforms without hooks: block and marker agree.
- [ ] `<collab>/methodology.md` and `<collab>/world/context.md` start with their load-check marker lines
- [ ] (Claude Code) `<collab>/docs/troubleshoot.md` exists (the load-check's local pointer target)
- [ ] (Claude Code) Hook script exists at `.claude/hooks/collab-memory-hook.sh` and is executable
- [ ] (Claude Code) `.claude/settings.json` contains hook entries for `SessionStart` and `UserPromptSubmit`
- [ ] `.gitignore` entries correct: solo without tracking → `collab/` + `.collab-config`; team → `/collab`, plus `.collab-config` and the new `CLAUDE.md` / `.claude/` files if the user chose to git-ignore the memory-system traces (Step 3)

**Final check — probe what actually loads (Claude Code).** The checks above verify files on disk; this one verifies the harness really injects them into context. Run a fresh, non-interactive probe from the project directory:

```bash
claude -p "Do NOT use any tools. From your system context ONLY: state whether a line containing COLLABMEM-MARKER- joined with METHODOLOGY, and a line containing COLLABMEM-MARKER- joined with CONTEXT, are present in your context. Begin your reply with the exact banner line your load-check instructions specify, then answer present/absent for the methodology marker and for the context marker — do not repeat the joined marker tokens themselves. Then stop: do not run the readmem orientation." < /dev/null
```

**Show the probe's raw output to the user verbatim — on both success and failure — then give a one-line plain-language translation.** Do not summarise it away or just declare success. This also holds for a re-run after a fix: paste the second probe's output too, so the user sees the SUCCESS banner with their own eyes rather than your report of it. If either marker is reported absent, the imports are not loading (common cause on team/symlink installs: external-import approval — see the troubleshooting guide copied in Step 6) — resolve before continuing, explaining the problem and fix in plain language (no jargon about markers/imports/config; offer technical detail only if the user asks). If you cannot run the probe from inside your session, ask the user to run it in a terminal from the project directory and paste the output.

**The probe's result is its answer.** If the output contains the `LOADED SUCCESSFULLY` or `FAILED TO LOAD` banner, or the present/absent answer for the two markers, that is the load-check result; anything the CLI prints around it (warnings about connectors, API keys, trust) is noise. Only a probe that produced *no answer at all* — because it failed to authenticate or errored out before answering — is not a load-check result: it says nothing about the markers, so do not treat it as a missing marker and do not start diagnosing imports. Find out why it failed. If the user can fix it, tell them how in plain language (e.g. an expired CLI login: run `claude login` in a terminal; a missing CLI: install it), then re-run the probe.

If the CLI is not available at all — e.g. the Claude native app without a terminal install, and the user does not want to install it — fall back to a fresh session: the load-check block prints the `LOADED SUCCESSFULLY` or `FAILED TO LOAD` banner in its first response, which establishes the same fact.

If any checks fail, report which ones and ask the user how to proceed. For issues that cannot be resolved, the user can file an issue at https://github.com/visionscaper/collabmem/issues.

**Commit the installation** once all checks pass, with the user's approval:
- **Standalone memory project:** commit and push (the remote from Step 2).
- **Team:** commit and push the shared-knowledge repo (only that repo) so teammates receive the new memory files. In the code repo, commit whatever the Step 3 tracking choice tracks — at minimum the `.gitignore` change. Tell the user these changes are committed but not yet pushed; pushing the code repo is their normal workflow.
- **Solo:** commit in the code repo; pushing is the user's normal workflow.

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
- Installation type: <solo | standalone memory project | team (distributed)>
- Collab directory location: <actual path, e.g. `./collab/` or `/path/to/shared-knowledge/projects/project-x/collab/`>
- For team installations: symlink `collab` → `<target>` created in project root
- Import placement: <at end of file | at start | after specific section> in <instruction file name>
- Git tracking: `.collab-config` <committed | git-ignored>; collab directory <tracked | git-ignored | external repo>
- Hooks installed: <yes (Claude Code: SessionStart, UserPromptSubmit) | skipped (other platform)>
- Hook overlap handling: <none | kept both | called from existing hook | replaced>
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
| DD-MM-YYYY | @<username> | Collaboration Memory System Installed | Initial collabmem installation: <solo/standalone/team>, hooks, world population status. First episodic note and index entry. | installation, setup, v<X.X>, <solo/standalone/team> |
```

**Closing rule:** conversations rarely end at the install summary — follow-up questions and small tasks (commits, pushes, tweaks) usually come after, and a reminder given earlier gets buried. Whatever the last exchange turns out to be, when the installation completed successfully your final message before parting MUST end by repeating: *"Reminder: the memory system activates in a new session — start one to begin using it."* If the installation did not complete, end instead by stating clearly what is still unfinished.

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
> ln -s <relative or absolute path to shared-knowledge/projects/project-name/collab> collab
> ```
>
> **Windows (PowerShell, requires developer mode or admin):**
> ```powershell
> New-Item -ItemType SymbolicLink -Path collab -Target <path to shared-knowledge/projects/project-name/collab>
> ```
>
> **Windows (cmd, requires admin):**
> ```cmd
> mklink /D collab <path to shared-knowledge\collab\project-name>
> ```

**If `.collab-config` is git-ignored, also include its contents in the final message** so each dev can easily reproduce it:

> "Since `.collab-config` is git-ignored, each dev also needs to create it in the project root. Contents:
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

### Step 11: Support the Project (starmem)

After delivering the final installation message from Step 9 — or, when a migration immediately follows in the same session, after the migration outcome message — run the `starmem` procedure: read `<collab>/support.md` and follow it (first ask). It asks the user, on behalf of the collabmem developers, to support the project by starring the GitHub repo, and records the answer in `.collab-config`.

Because the star ask now becomes the last exchange, the closing rule still applies: end this message too with the restart reminder — *"Reminder: the memory system activates in a new session — start one to begin using it."*
