<!-- GENERATED from templates/install.md by tools/build_instructions.py. Edit the template and its field files, not this file. -->

# Collaboration Memory System — Installation

These instructions are for you, the AI assistant. Follow them step by step to install the collaboration memory system into the user's project. The system gives you long-term episodic and world model memory that survives across sessions and context compaction.

## Communicating with the User

When communicating with the user you must follow these instructions. They help the user understand what you want to convey, and make communication easier and more effective for them.

### General principles

To understand the rules below, here are two principles about people that determine how to communicate with the user.

**People have no context window.**

You hold everything you have read: files, command output, these instructions, your own conclusions.

The user holds an abstract mental model of what they are working on, what they learned and what they decided. It is built from what they already knew and from what reached them over time. They have limited capacity for specific details: they remember gists, and where or how details can be found.

The user may also not have read everything you wrote. A long or dense message gets skimmed, and their attention may have been on something else.

So every message must carry its own context. The exception is context that is top of mind for the user: what they just said themselves, or what you just discussed together. Something that only appeared in an earlier message of yours does not count.

**People process text visually, in two dimensions.**

Vertical spacing, visual structure and highlighting are therefore not decoration. They do three things:

- they separate text into conceptual blocks;
- they give meaning through structure, for example through indent levels of bullet points;
- they draw the eye to the important pieces.

A wall of text, without any visual structure, is the opposite. It is very hard for people to read.

### How to communicate with the user: the rules

**1. Start with what it means for the user.**

Say what the matter is, why it matters to them, and what they need to decide or do. Mechanism, file names and commands come after, and only as much as the user needs.

Offer technical detail on request, unless the technical detail is the point of the message.

**2. Carry the context.**

Assume the user does not have your context, as explained above.

- Explain a term in plain words where you first use it.
- Say what "this", "it" or "both" refer to.
- Say what you did and found before you show a result.
- Never refer to things the user has not seen: step numbers, section names or file names from these instructions.

**3. Keep it short and plain.**

- Keep the text simple: no dense language, short sentences. One idea per paragraph.
- No sub-sentences in brackets. If it is worth saying, give it its own sentence.
- As long as it needs to be, and no longer.

**4. Lay it out to be read.**

- Blank lines between points.
- Bullets for parallel items, one item per bullet.
- Options listed below each other, never in one long sentence.

**5. Highlight what must be read.**

Highlighting is a powerful tool. Use bold for the gist of a message, for a key piece of information, or for what the user must do. It can also set parts of a text apart.

Do not overuse it. When much is highlighted, nothing stands out.

**6. Make every choice a real choice.**

A choice comes with four things: what it is about, the options and what each means, when to choose which, and the default with its reason.

Ask one question at a time. Offer to answer questions before the user decides.

**7. Ask before you act.**

Where something is the user's call, propose and wait. That holds for choices, and for actions the user would want to know about first.

**8. End every turn with a message that stands on its own.**

The user may read only your last message. So it says what you did in this turn, and gives enough context to understand the question or result it ends with.

**9. Show results as they came, then translate.**

Paste important output unchanged. Follow it with one plain sentence on what it means, and what needs to be done if anything.

**10. Reassure where it is true.**

When something goes wrong: name it, say whether it is common, and say whether it is likely easy to fix. Then say what you will look at.

### Additional rules during installation

**Start by saying what you are installing.**

After you have read these instructions, and before anything else, tell the user in one or two sentences what collabmem is. For example:

> "collabmem is a memory system that lets us collaborate over the long term, building up the memory over time."

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
collab/                     → (solo and standalone: a real directory | distributed: a symlink into the shared-knowledge repository)
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

collabmem can be set up in three ways. The user chooses in step 2. `setup-options.md` describes each setup in detail: read it before you start.

- **Solo** — the memory lives inside the code repository, as a real `collab/` directory.
- **Standalone memory project** — there is no code repository; the memory repository *is* the project, and `collab/` is a real directory inside it.
- **Distributed** — the memory lives in a separate shared-knowledge repository; the code repository reaches it through a symlink named `collab`.

The steps below use these three names. Solo and standalone install in the same way: `collab/` is a real directory in the project. Where a step differs for the distributed setup, it says so.

**Two placeholders in the steps.** `<collabmem>` is the folder where you cloned collabmem. `<collab>` is the memory directory: `collab/` in the project for solo and standalone, `projects/<project-name>/collab/` in the shared-knowledge repository for distributed.

**Project root.** Throughout this document, "project root" means the directory the AI session is rooted in. For the solo and distributed setups that is the root of the code repository. For a standalone memory project it is the memory project's own directory: the repository root when the project has its own repository, or `projects/<name>/` when it lives inside a shared-knowledge repository that holds several memory projects. In the distributed setup it never means the separate shared-knowledge repository.

**Memory-system traces.** The files collabmem puts in the project *besides* the memory itself: `.collab-config` at the project root, the import block in the instruction file, and `.claude/` with the hook script and its `settings.json` entries. In a distributed setup these are the only collabmem files in the code repository, and the user chooses in step 3 whether they are committed or git-ignored.

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

### 7 - Verifying the installation

Two checks: the files are in place, and a fresh session really loads the memory.

#### 7.1 - The files are in place

Check the points below. Tell the user the outcome in a sentence or two, not as a list.

- `.collab-config` is at the project root.
- In a distributed setup: the `collab` symlink is at the project root and leads to the memory directory.
- The memory directory holds its version file `.collab-memory-system`, the twelve memory files (`methodology.md`, `support.md`, `index.md`, `index-archive.md`, `notes.md` and the seven world files), and the `docs/` directory.
- `methodology.md` and `world/context.md` start with their load-check marker lines.
- The instruction file holds the collabmem block between its two markers, including the `COLLABMEM-LOAD-CHECK` section.
- The three version stamps agree: the first line of the block, the header of the hook script, and `.collab-memory-system`. Without hooks: the block and the version file.
- Claude Code: the hook script is in `.claude/hooks/` and executable, `.claude/settings.json` has its entries for `SessionStart` and `UserPromptSubmit`, and `docs/troubleshoot.md` is in the memory directory.
- `.gitignore` has the entries from step 4.

#### 7.2 - A fresh session really loads the memory (Claude Code)

Files in the right place do not prove that Claude Code loads them. The load check does: it starts a fresh session in the background and asks it whether the memory files are in its context.

Tell the user that, before you run it. Then run this from the project directory:

```bash
claude -p "Do NOT use any tools. From your system context ONLY: state whether a line containing COLLABMEM-MARKER- joined with METHODOLOGY, and a line containing COLLABMEM-MARKER- joined with CONTEXT, are present in your context. Begin your reply with the exact banner line your load-check instructions specify, then answer present/absent for the methodology marker and for the context marker — do not repeat the joined marker tokens themselves. Then stop: do not run the readmem orientation." < /dev/null
```

**Show the result as it came.** Paste the output unchanged, on success and on failure, and follow it with one plain sentence on what it means. The same holds for every later run: the user sees the `LOADED SUCCESSFULLY` banner themselves, not only your report of it.

**What counts as a result.** The banner, `LOADED SUCCESSFULLY` or `FAILED TO LOAD`, or the present/absent answer for the two markers. Anything the command prints around that is noise. A run that gave no answer at all, for example because the login expired, says nothing about the memory. Find out why it failed, help the user fix that, and run it again.

**If you cannot run the command,** ask the user to run it in a terminal in the project directory and paste the output. If the `claude` command is not installed at all, a fresh session does the same job: its first response starts with one of the two banners.

#### 7.3 - When the load check fails

In a distributed setup this is common and easily fixed. The memory sits outside the project, and Claude Code needs a one-time approval before it loads files from outside a project. Issue 1 of the troubleshooting guide you copied locally in step 6 has the fix.

Tell the user, in plain words and in this order:

- what happened, and what it means;
- that it is common for this setup, and likely easy to fix;
- what you will investigate;
- what you found;
- what fix you propose, and ask whether they agree;
- after the fix: run the load check again, and show its result.

Keep setting names, file paths and your reading of the guide out of it, unless the user asks.

### 8 - Seeding the memory with the user's context

The memory starts empty. Ask the user for some high-level context, and strongly recommend giving it. Say why: it frames everything the AI does from now on, and high-level context rarely comes up by itself later in the work.

Ask this:

> "To give the memory a good start, could you tell me in a few sentences:
>
> - what this project is about, and what your role in it is?
> - what you are currently working on?
> - how you like to collaborate: communication style, level of detail?
>
> Anything else you want me to know is welcome too."

For a standalone memory project there is no code to start from. Ask about the person and the purpose instead: who they are and what they do, what they want to use this memory for, and the project, study or business it is about.

If the user does not want to do this now, accept that. But do not present skipping as just as good.

**Writing it down.** Put the answers where they belong, in this order:

1. `world/context.md`: who the user is, the project, the business, constraints, technology. It frames the rest.
2. `world/preferences.md`: how they like to communicate and work.
3. `world/domain.md`, `world/how-tos.md`, `world/factoids.md`: domain knowledge, procedures and specific facts, if any came up.
4. `world/state.md`: what they are working on now.

Replace the placeholder comments in those files with the content, and keep the headings. Then show the user what you wrote, so they can correct it.

**Existing documents.** If the project has documents the AI should know, such as design documents or analyses, tell the user they can be brought into the memory's `docs/` directory, and offer to do that now or later.

### 9 - Writing the installation note

The first note in the memory records the installation. It shows the user what a note looks like, and it gives a new session something to find when the user checks that the memory works.

Read `<collab>/methodology.md` first if you have not yet. Its "Notes Protocol" defines how notes and index rows are written, and it is the source of truth when it differs from the templates below.

Append the note to the bottom of `<collab>/notes.md`, with today's date. The template shows the minimum. Write it as a real note: expand where there is something to say.

```
---

### [DD-MM-YYYY] Collaboration Memory System Installed

**With:** @<username> (use `git config user.name` by default; if unclear or empty, ask the user)

**Context:** Initial installation of the collabmem system on this project. Describe briefly why the user wanted the memory system and any relevant project/team context.

**What We Did:**
- Installed collabmem version <vX.X> (from `<collab>/.collab-memory-system`)
- Setup: <solo | standalone memory project | distributed>
- Memory directory: <actual path, e.g. `./collab/` or `/path/to/shared-knowledge/projects/project-x/collab/`>
- In a distributed setup: symlink `collab` → `<target>` created in the project root
- Import placement: <at end of file | at start | after specific section> in <instruction file name>
- Git tracking: `.collab-config` <committed | git-ignored>; collab directory <tracked | git-ignored | external repo>
- Hooks installed: <yes (Claude Code: SessionStart, UserPromptSubmit) | skipped (other platform)>
- Hook overlap handling: <none | kept both | called from existing hook | replaced>
- Seeding with the user's context: <done | not now>. If done, summarise what kinds of context the user provided and which world files were filled.
- Anything else relevant: issues encountered and how they were resolved, user decisions made during install, deviations from defaults.

**`.collab-config` contents:**
```
<paste actual file contents here>
```

**Key Learnings:**
- Memory system is now active and will load automatically on new sessions.
- <In a distributed setup:> teammates who clone the code repository later need to create their own `collab` symlink, and approve external imports once.
- Add any other observations: what worked smoothly, what caused friction, what the user should know going forward.

**Related:** `collab/methodology.md`, `collab/.collab-memory-system`
```

Then add its row to `<collab>/index.md`:

```
| DD-MM-YYYY | @<username> | Collaboration Memory System Installed | Initial collabmem installation: <solo/standalone/distributed>, hooks, seeding status. First episodic note and index entry. | installation, setup, v<X.X>, <solo/standalone/distributed> |
```

### 10 - Migrating an existing notes system

Only when check 1.4 found one. Migration is optional: the user may prefer to start fresh and keep the old notes as an archive.

1. **Discuss whether to migrate.** Tell the user what you found: the format, how many entries, how they are organised. Are the notes still relevant, and would the project benefit from having this history in the memory?

2. **Plan it together.** Decide how the old entries map: which are episodic notes for `notes.md`, which are logs of a special kind such as experiment logs, and which are project context that belongs in the world model. The user knows things about the old system that you cannot see.

   If the old system has an index, check whether it covers all notes, and plan index rows for the ones it misses.

   Before you start, list the kinds of world-model topics this project could have, such as architecture decisions, constraints, domain knowledge, procedures and key facts. That list helps you recognise them while migrating.

3. **Migrate the notes and the index, in bulk.** The differences between formats are usually small and mechanical, so transform rather than rewrite.

   - Notes: a `###` heading with a `[DD-MM-YYYY]` date, a `**With:**` field, `---` between notes.
   - Index: the columns `Date | Who | Title | Summary | Keywords`.
   - Special logs go to their own files, reference documents to `docs/` in the memory directory.

   Notes are historical records. Leave the paths and references inside them as they were, except for files you move as part of this migration.

4. **Then fill the world model from the migrated notes.** Read them as a whole, or in batches, and write by topic, not by note: first `context.md` and `preferences.md`, then the other world files, then `state.md`. Update `world/index.md` whenever `domain.md`, `how-tos.md` or `factoids.md` change.

5. **Keep track across sessions.** For a large set of notes, record the progress in `world/state.md`, for example "Migration: 45 of 184 notes done". The next session sees it at once.

6. **Write a migration note** when the migration is done, or at the end of each migration session: what was migrated, what was decided, what went wrong, what was learned. With its index row.

While a migration is under way, recommend adding this comment just above the collabmem block in the instruction file. It tells every AI session which system is leading:

```markdown
<!-- IMPORTANT: We are transitioning from the old memory system (above) to the collaboration memory system (below).
     The new system is authoritative where it covers a topic. Old content will be progressively migrated and removed. -->
```

### 11 - Committing the installation

Everything is written now: the memory, and the installation note. Tell the user what will be committed and where, and ask for their consent.

- **Solo:** commit in the code repository. Do not push: pushing is part of the user's normal workflow.
- **Standalone:** commit and push. The remote is the memory's backup.
- **Distributed:** two repositories.
  - The shared-knowledge repository: commit the new memory directory and push, so teammates receive it. Commit nothing else there.
  - The code repository: commit what the user chose to track in step 3, at least the `.gitignore` change. Tell the user it is committed but not pushed: pushing the code repository is part of their normal workflow.

### 12 - The star ask

The installation is done and committed. Before you close it off, read `<collab>/support.md` and follow it: the first ask. It relays a short message from the collabmem developers, asking the user to star the project on GitHub.

The answer is recorded in `.collab-config`. If that file is tracked, commit that one change, in the same way as in step 11.

### 13 - Closing the installation

The final message tells the user four things, in plain words.

1. **That collabmem is installed.** For example:

   > "The collaboration memory system is installed, and a first note has been written. It becomes active in a new session: the methodology, the memory files and the hook load automatically. The system will build up knowledge naturally as we collaborate."

2. **How to check that it works.** In a new session, ask one of:

   - "What kinds of memory do you have, and how do they work?" It shows that the methodology is loaded.
   - "What do you know about this project?" It shows that the world model is loaded, if the user gave context.
   - "What is the last thing we did?" It shows that the notes index is loaded: the AI should mention the installation note.

3. **How to get help.** In a new session, type `helpmem`, or `helpmem` followed by a question.

4. **In a distributed setup: what a teammate does after cloning the code repository.** They create their own `collab` symlink, and approve external imports once. Issue 1 of the troubleshooting guide explains that approval.

   ```bash
   # macOS and Linux
   ln -s <path to shared-knowledge>/projects/<project-name>/collab collab
   ```

   ```powershell
   # Windows PowerShell, needs developer mode or admin rights
   New-Item -ItemType SymbolicLink -Path collab -Target <path to shared-knowledge>\projects\<project-name>\collab
   ```

   If `.collab-config` is git-ignored, include its contents too, so a teammate can recreate it.

**The last line is always the same.** Conversations rarely end at this message: questions and small tasks follow, and a reminder given earlier gets buried. So whatever your last message turns out to be, it ends with this line, highlighted:

> **Reminder: the memory system activates in a new session — start one to begin using it.**

If the installation did not complete, end instead by saying clearly what is still unfinished.
