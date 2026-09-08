# collabmem — Setup Options

This document describes the ways collabmem can be set up, and what each way means for where files live, how many copies of them exist, and how they are upgraded. Read it before installing (`install.md`) or upgrading (`upgrade.md`). This is the reference; the README only gives the short overview.

## Why this matters

collabmem is a set of files. Where those files live depends on how you use it: alone or with others, with a code repository or without one, in a public repository or a private one. The choice affects three things:

- where the memory is stored, and who can see it
- where the instruction file and the hooks are placed
- whether upgrading once upgrades everything, or whether some parts must be upgraded per copy

## Terms

The rest of this document uses these terms, and only these, for the things involved.

**Memory project.** One collabmem memory: a collab directory with its notes, indexes, and world files, plus the settings that make the AI load it. Every setup below is about where one memory project lives.

**Code (or other work) repository** — short: *code repository*. The git repository holding the work the memory is about: code, but just as well documents, research, or anything else worked on in a repository. A memory project has one code repository in the distributed and solo setup options, and none in the standalone option.

**Shared-knowledge repository.** A git repository whose purpose is memory: it holds one or more memory projects and no code. This is the methodology's term; "memory repository" means the same thing.

**Clone.** One checked-out copy of a repository on one machine. Several people, or one person on several machines, means several clones of the same repository.

**Project root.** The directory the AI session is rooted in, also called the session root: the root of the code repository, or the memory project's own directory. The instruction file and the hooks always live here.

**Shared part and per-clone part.** The two parts every install is made of, defined fully in "The two parts of an install" at the end. In short: the shared part is what lives in the collab directory; the per-clone part is what lives at the project root to load it, and it exists once per clone.

## Where the instruction file and hooks go

Always at **project level**, at the project root (see Terms):

- `./CLAUDE.md` or `.claude/CLAUDE.md` for the instruction file
- `.claude/hooks/` and `.claude/settings.json` for the hooks

Which repository that is depends on the setup. It is the code repository in the solo and distributed setups, and the memory project's own directory in the standalone setup, see "The three setups" below.

Never install into a user-level instruction file such as `~/.claude/CLAUDE.md`. A user-level file loads in every session on the machine. One project's memory, hooks, and load-check would then fire in every other directory too, and relative paths would have no fixed project root to resolve from. A user-level install next to a project-level one is a duplicate install; see the troubleshooting guide.

## Multiple memory projects in one repository

A shared-knowledge repository does not have to serve a single memory project. One repository can hold many, each under its own directory:

```
shared-knowledge/
├── projects/project-x/collab/
├── projects/project-y/collab/
└── projects/project-z/collab/
```

Each memory project decides for itself which of the setups below it uses. A memory project with a code repository is a distributed project: the code repository reaches this directory through its `collab` symlink. A memory project without a code repository is a standalone memory project: sessions are rooted in its directory, and its instruction file and hooks live in that directory's `.claude/`, committed with the memory. Mixing the two in one repository is normal. An organisation's shared-knowledge repository typically has both: some projects are code, some are not.

The advantage: all your memories are together, in one place to back up, search, and reason across.

The cost: pulls and pushes cover the whole repository. Before you can push your project's changes you pull everyone's, including changes to projects you do not work on, and merge friction in one project is felt by all. Commits should be scoped to the project directory being worked on.

## The three setups

### 1. Solo — memory inside the code repository

This setup is possible, but **discouraged for software projects that work with branches**. It only works well for a single user, on a private repository, who commits on the main branch only. In all other cases, use the distributed setup.

- The collab directory is a real directory at the root of the code repository, tracked by git.
- The instruction file and hooks live in that same repository.
- There is one copy of everything. Upgrading is a single pass.
- Memory travels with the code: same branches, same commits, same visibility.

Commit the memory changes after every `updatemem`, so they are not left dangling in the working tree. Pushing goes with your normal code workflow: the AI does not push a code repository on its own, since that would also push your code. The repository should have a remote for the same reasons as in the standalone setup below.

Why it is discouraged:

- **Memory gets stuck in branches.** A memory update committed on a feature branch is invisible on main and on every other branch until that branch merges. If the branch is abandoned, the memory goes with it. Keeping one growing memory then requires constant care, and the moment that care lapses, the memory silently forks.
- **Public repositories** — project decisions, business context, preferences, and strategic discussions become public.
- **Repository churn** — code changes and memory changes interleave in one history, cluttering both.
- **Access control** — everyone with access to the code has access to the memory.
- **Memory as first-class history** — memory changes deserve their own commit history and review flow.

### 2. Standalone memory project — the memory repository is the project

Used when there is no code repository, or when the memory is the work itself. Examples: an organisation-level memory, a research or business project, a non-technical user's working memory.

- The memory project has its own repository, or is a project directory inside a shared-knowledge repository that holds several memory projects (see "Multiple memory projects in one repository" above). Either way it contains the collab directory and nothing else that is worked on independently.
- The instruction file and hooks live in the project's own `.claude/`, and are committed with it.
- Sessions are started inside the project: the repository root, or the project directory in a shared repository. Commits are scoped to that project.
- Because the per-clone part is committed, every clone of the repository gets the same copy on pull. There is one copy of everything, as in the solo setup, even when several people or machines use it.

Give the repository a remote, and commit and push after every `updatemem`. With a remote in place, a standalone memory project's repository is by default a shared-knowledge repository in the methodology's sense, and its pull and push rules apply. Two reasons for the remote:

- the remote is the backup of the memory
- a solo memory often becomes a shared one later, when a second machine or a second person joins; with a remote in place, that is a clone, not a migration

### 3. Distributed — memory in a shared-knowledge repository

Used by teams, by single users working from several machines, and by single users who want private working memory kept out of a public code repository.

- The memory lives in a separate shared-knowledge repository.
- Each clone of the code repository has a git-ignored symlink named `collab` pointing into the shared-knowledge repository. Every developer creates their own.
- The instruction file and hooks live in the code repository. They are per clone: if the instruction file is git-ignored, each developer has their own copy; if it is committed, all clones share it, but the hooks and settings may still differ per machine. Note what that means for the stamps: committed files carry one stamp for all clones — with the default of committing all traces, both the block's and the hook's stamp are shared, and a clone is behind only until it pulls. Only git-ignored copies have a stamp of their own. The upgrade procedure checks both stamps either way.

Two patterns for the shared-knowledge repository:

- **One repository for all projects** — for example `shared-knowledge/projects/project-x/collab/` and `shared-knowledge/projects/project-y/collab/`, leaving room for other project material next to each `collab/`. Centralises team knowledge, simplifies cross-project awareness, one access list to manage. The good default for most teams. Such a repository may also hold standalone memory projects next to the distributed ones; see "Multiple memory projects in one repository" above.
- **One repository per project** — when projects have different teams with different access, or must stay fully isolated, for example for client confidentiality or regulatory reasons.

Consequences for upgrading:

- The shared part is upgraded once. Everyone gets it on the next pull of the shared-knowledge repository.
- The per-clone part must be checked, and updated where needed, in each clone separately, from a session in that clone. The version stamps make this checkable.

Consequences for daily use:

- The shared-knowledge repository is pulled before reading memory and pushed after updating it, so that concurrent sessions and other machines see each other's changes.
- Imports that resolve outside the project directory through the symlink need the harness's permission to do so. See `clients/claude-code/troubleshoot.md`, Issue 1.

## The two parts of an install

The three setups differ in where files live, but every install is made of the same two parts. They are versioned separately.

**The shared part** is the collab directory. Its location is the `collab_dir` value in `.collab-config`. It contains:

- `methodology.md` — the AI's operating instructions
- `support.md` — the starmem support-ask procedure
- `docs/troubleshoot.md` — the troubleshooting guide, copied at install
- the memory itself: notes, indexes, the `world/` files, and the `docs/` reference documents
- `.collab-memory-system` — the version marker

**The per-clone part** is what makes the harness load the shared part:

- the import block in the instruction file, between the `<!-- collab-memory-system:start -->` and `<!-- collab-memory-system:end -->` markers
- the hook script, for harnesses that support hooks

In the solo and standalone setups both parts sit in the same repository, so there is one copy of each and they are upgraded together. In the distributed setup the shared part sits in the shared-knowledge repository and the per-clone part in each code-repository clone, so the shared part exists once and the per-clone part once per clone. That is why upgrading a distributed install has two halves.

Each per-clone copy carries its own version stamp:

- the first line inside the import block: `collabmem instruction block, checked and updated up to: vX.Y.Z`
- a header line in the hook: `# collabmem hook, checked and updated up to: vX.Y.Z`

The stamp means: this copy was checked, and updated where needed, up to that version. The shared version marker cannot say this about any particular copy. The upgrade procedure compares both.

## Quick comparison

| | Solo | Standalone memory project | Distributed |
|---|---|---|---|
| Memory lives in | the code repo | its own repo, or a project directory in a shared-knowledge repo | a shared-knowledge repo |
| Session rooted in | the code repo | the memory project's directory | the code repo |
| Instruction file and hooks in | the code repo | the memory repo, committed | each code-repo clone |
| Copies of the per-clone part | one | one | one per clone (identical when the traces are committed) |
| Upgrade | single pass | single pass | shared part once, per-clone part per clone |
| After `updatemem` | commit; push with your code | commit and push | commit and push, the shared-knowledge repo only |
