# collabmem — Troubleshooting

Diagnostic procedures for when the memory system appears installed but does not behave as expected.
Written for AI agents to follow directly. Symptom-first: find your symptom, run the checks, apply the fix.

**Scope note.** collabmem itself is just markdown files plus a hook. Most "collabmem is broken" reports are
not collabmem bugs — they are *harness* problems (the agent CLI failing to load the memory files) or
*layout* problems (paths, symlinks, config). This document covers those, because from the user's side they
are indistinguishable from a memory failure.

**Applies to:** collabmem v1.8.5 (compare with the installed version in
`<collab_dir>/.collab-memory-system`; if they differ, prefer the copy shipped
with your installed version — see the version-lookup procedure in the
methodology's helpmem section).

**Verified against:** Claude Code `2.1.246` on macOS (darwin), 26-08-2026 — every observation, config key,
and probe below was checked on that build. The regression in Issue 1 appeared between `2.1.177` (working)
and `2.1.246` (broken). Treat behaviour on other versions or other CLIs as unconfirmed: the diagnostic
*method* is portable, the specific key names and flags are not.

**A note on trust.** Harness behaviour referenced below is version-specific. Never rely on remembered
behaviour of a CLI — verify against the build actually installed, and check the public issue tracker before
concluding you have found something new.

---

## Start here

You are here because a load-check failed or memory content is missing. Before
diagnosing:

**How to communicate throughout.** Use plain language with the user. Do not
assume they know what the load check, markers, imports, symlinks,
external-includes approval, or harness config are. Describe the problem by its
effect ("the memory files didn't load") and describe any fix by what it
achieves for them ("this lets this project read its team memory again"), not
by its internal mechanism. Offer technical detail only if they ask. When you
run a diagnostic probe, show its raw output verbatim AND give the plain-language
translation.

1. **Get your bearings — read the local files if reachable:**
   `<collab_dir>/methodology.md` (how the memory system works) and
   `<collab_dir>/world/context.md` (who you are helping, and with what —
   specifically the context). If the local files are unreachable, fetch only
   the methodology from
   https://raw.githubusercontent.com/visionscaper/collabmem/refs/heads/main/collab/methodology.md
   and proceed without user context — tell the user you are missing it.
   (`world/context.md` is local-only by nature: it is private and has no
   canonical URL.) Note: once you read memory files with tools, the
   in-context marker check is no longer meaningful for this session — from
   here on, only the fresh probe (Check 3) is authoritative.
2. **Route by symptom:**
   - Instruction file loaded but Tier 1 memory files absent (marker check
     failed; imports show as literal `@...` lines or content is missing) →
     **Issue 1**.
   - The COLLABMEM-LOAD-CHECK section itself is absent (the instruction file
     never loaded) → **Issue 3**.
   - Session-start hook prints an error → **Issue 2**.
   - The methodology marker appears **more than once**, or session start
     shows **two or more** collabmem hook blocks (identical or not) → **Note —
     duplicate installs** (more than one install imports the same memory).
   - Which marker is missing is a signal: only one missing → likely a single
     broken import line (check the import paths, Issue 1 fix list); both
     missing → whole-block failure (approval flag, symlink, directory —
     Issue 1 root cause).
   - Symptom not listed → follow "Technique — investigating harness
     behaviour" below; check the harness's public issue tracker (see "Known
     upstream reports") and the collabmem issue tracker
     (https://github.com/visionscaper/collabmem/issues) for known cases.

---

## The files this document refers to

If you are debugging an install you did not set up, this is the layout. **Tier 1** files are injected into
your context automatically on every session; **Tier 2** files are searched on demand.

```
.collab-config                  ← system settings (at project root)
collab/
├── .collab-memory-system       ← version marker
├── methodology.md              ← AI operating instructions
├── support.md                  ← starmem support-ask procedure
├── index.md                    ← episodic memory index (Tier 1 — always in context)
├── notes.md                    ← episodic memory (Tier 2 — searched on demand)
├── index-archive.md            ← archived index entries (Tier 2)
├── docs/                       ← long-form reference documents (Tier 2)
│   └── troubleshoot.md         ← this guide, copied here at install (Claude Code)
└── world/
    ├── index.md                ← world model index (Tier 1)
    ├── context.md              ← personal, project, business context (Tier 1)
    ├── preferences.md          ← user working preferences (Tier 1)
    ├── state.md                ← current work in progress, todos, blockers (Tier 1)
    ├── how-tos.md              ← procedures for recurring tasks (Tier 2)
    ├── domain.md               ← domain-specific knowledge (Tier 2)
    └── factoids.md             ← specific facts, numbers, references (Tier 2)
```

`collab/` is the memory directory; its location comes from `collab_dir` in `.collab-config`. Depending on the
setup it is a real directory in the repository, or a **symlink to a shared-knowledge repo outside the project** —
the distributed setup, which is what makes Issue 1 possible. The setups and where files live in each are
described in `setup-options.md` in the collabmem repository.

The project **instruction file** (`CLAUDE.md` or your CLI's equivalent) is *not* part of this tree. It
contains the `@` import lines that pull the Tier 1 files in. It loads normally even when every import
fails — which is why the failure is so easy to miss.

---

## Issue 1 — Tier 1 files are not in context (`@` imports silently not expanded)

The most consequential failure mode in the system, because **it is silent**. The memory system's own files
are the thing that failed to load, so every instruction about how to handle it is also missing. The system
cannot tell you it is broken using its own files — any recovery instruction must live in the always-loaded
instruction file (the `CLAUDE.md`-equivalent) or in this document.

### Symptoms

- On pre-v1.8.5 installs: the session-start hook prints *"Tier 1 files loaded via imports"*, but you
  cannot find current-work or index content anywhere in your context. (v1.8.5 hooks no longer assert
  loading — they instruct a check; a failed check reports the FAILED banner instead.)
- You have the *instruction file* but the memory files it imports are absent.
- The contents of the imported memory files appear nowhere in your context — only the **literal
  `@path/to/file.md` lines** exist (note: literal `@` lines by themselves are normal in some harness
  renderings; it is the absence of the file contents that matters).
- A context-usage breakdown lists only the instruction files themselves under "Memory files", not the
  imported memory files.
- You compensate without noticing: for instance, you read `world/state.md` manually on `readmem`, everything seems fine,
  and the failure never surfaces. **Watch for this** — silent compensation is how this survives for weeks.
  Compensating is fine; compensating *without telling the user* is the failure.
- No error, no warning, anywhere.

### Fast diagnosis

**Check 1 — inspect your own context.** Does the CONTENT of the imported files appear anywhere in your
context window? Note that harnesses may keep the `@...` lines literal even on success and place the
imported content elsewhere (e.g. as separate labelled blocks) — a literal `@` line alone proves nothing;
the absence of the files' content anywhere is what indicates the imports were not expanded. On v1.8.5+
installs the two `COLLABMEM-MARKER-` lines are the definitive probe targets. Cheapest check, usually
conclusive.

**Check 2 — what the harness thinks it loaded.** If your CLI exposes a context breakdown (e.g. a
`/context` command), read its "Memory files" section. Imported memory files should be listed individually.

**Check 3 — the decisive probe (recommended).** Run a *fresh, separate* instance of the CLI in
non-interactive mode and ask it what it received:

```bash
# from the project directory; set the config-dir env var if you use a non-default one
claude -p "Do NOT use any tools. From your system context ONLY: list the exact paths of every file whose \
CONTENTS were provided to you. Then state whether the text following the Tier 1 import header is actual \
file content or a literal '@...' path line." < /dev/null
```

Why this is the key technique: a fresh process re-reads config and instruction files from scratch, so it
separates **"my long-running session is stale"** from **"loading is genuinely broken"**. It also lets you
test a fix *without* restarting your own session. Use `< /dev/null` so the call does not wait on stdin.

Adapt the flag names to your CLI; the essential properties are: new process, non-interactive, same project
directory, same config directory.

**Check 4 — search the public record.** Before theorising about internals, search the CLI's issue tracker
and recent release notes for your symptom. This class of bug is usually already filed, and the public record
tells you *why the behaviour changed*, which local inspection cannot. See "Known upstream reports" below.

### Root cause — external-import approval is not granted

Start here; this is the common case.

collabmem is frequently installed with the memory directory **outside the project** — typically the
shared-knowledge-repo pattern, `collab -> ../<knowledge-repo>/collab`. The imports therefore resolve to
files outside the project tree, which agent CLIs treat as a **security-relevant "external include"**:
allowing it means a repository can pull arbitrary local files into your context. CLIs therefore require
explicit, **per-project** user approval, stored as a boolean in the CLI's own config.

**When that approval is missing or `false`, external imports are dropped silently.** The instruction file
still loads; the `@` lines simply expand to nothing. That is the whole failure — no error path, no warning.

Common reasons the approval is not in place:

- It was never granted (the dialog was never shown, or was dismissed/declined once — a decline is sticky).
- The config directory was moved, recreated, or restored from a backup: per-project entries revert to
  defaults.
- New machine, fresh clone, or the project moved to a different path — approval is keyed by project path.
- The CLI changed where or how it stores this state between versions.

**Distinguishing evidence.** Imports written as plain in-project relative paths (e.g. `@.collab-config`)
keep working while every import that reaches outside the project fails. That split isolates the cause to
path resolution and permissions, not to a malformed instruction file.

Go to *Confirming it* below. For most installs, granting the approval is the whole fix.

#### The tricky case — it worked yesterday and the flag never changed

Worth knowing, because it produces a misleading causal story and predicts recurrence.

If a pre-upgrade config shows the approval flag was **already `false` while imports demonstrably worked**,
then the flag was never the operative mechanism and something else started enforcing it. Observed on Claude
Code (working on 2.1.177, broken on 2.1.246, flag `false` throughout):

- Historically, in previous Claude Code versions, containment was checked on the **pre-resolution (literal)
  path** while the file was read **through the symlink**. An import written `@collab/...` looks internal, so
  it was never classified as external, the approval flag was never consulted, and the files loaded
  regardless of it. This was
  [reported as a vulnerability](https://www.tego.ai/blog/a-hidden-project-link-can-make-claude-code-silently-send-your-files-to-an-attacker):
  a hostile repo could commit a symlink and pull arbitrary local files into context with no prompt.
- Hardening the read path closes that hole — symlinked imports resolving outside the project are now
  refused unless approved. A long-dormant `false` flag becomes a silent, total loss of Tier 1.

**So do not assume "the upgrade reset my approval."** Check whether it was ever `true`. The fix is the same
either way; the story matters because it tells you the symlink-traversal install pattern sits on a code path
upstream is actively tightening, and will keep breaking. See the supported alternative under *Fix*.

### Confirming it

Locate the CLI config and read the per-project entry. For Claude Code the file is `.claude.json` inside the
config directory (`~/.claude` by default, or `$CLAUDE_CONFIG_DIR` if set), with these keys:

```
hasClaudeMdExternalIncludesApproved     # false -> external imports dropped
hasClaudeMdExternalIncludesWarningShown # false -> user has not been asked yet
```

```bash
python3 - <<'EOF'
import json, os
cfg = os.path.join(os.environ.get("CLAUDE_CONFIG_DIR", os.path.expanduser("~/.claude")), ".claude.json")
proj = os.getcwd()
p = json.load(open(cfg)).get("projects", {}).get(proj, {})
print(cfg, "\n", proj)
for k, v in p.items():
    if "ExternalIncludes" in k or k == "hasTrustDialogAccepted":
        print(f"  {k}: {v}")
EOF
```

If your CLI differs, search its config for keys containing `external`, `include`, `trust`, or `approve`.

### Why the approval dialog may never appear

Do not assume "restart and accept the prompt" will work. The dialog's classification still keys on the
**pre-resolution path**, so a symlink *inside* the project looks internal, nothing is flagged as external,
and no dialog is shown — while the read path resolves it, sees it escaping the project, and refuses.
Refused and never asked: the deadlock. This is the same asymmetry that produced the vulnerability above,
now visible from the other side.

Additionally, in observed builds the dialog renders only on a **fresh interactive start** — the startup path
returns early when a session is resumed or reattached. If you habitually resume sessions you would never see
it even when classification works.

So: if a genuinely fresh interactive start produces no prompt, stop waiting for it.

### Fix

**How to explain this to the user (plain language — do not relay the mechanics below).** The rest of this
section is for *you* to execute; it is not what you say to the user. Say something like: *"Claude Code's
settings for this project were blocking it from reading your memory files. I can turn that on for this
project — OK?"* After applying it: *"Done. Let's start a fresh session so I can confirm the memory loads."*
Only go into flags, symlinks, or config if the user asks for detail.

Setting the approval flag by hand is equivalent to answering "yes" in the dialog (which writes
`approved = true` and `warningShown = true`).

**Order matters.** Do this with **no session running for that project** — a live session may rewrite the
config on exit and silently revert your edit. If you must edit from inside a live session, re-verify after
it exits.

```bash
# 1. back up
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.claude.json"
cp "$CFG" "$CFG.bak-extimports-$(date +%Y%m%d)"

# 2. set the flags for this project only
python3 - <<'EOF'
import json, os
cfg = os.path.join(os.environ.get("CLAUDE_CONFIG_DIR", os.path.expanduser("~/.claude")), ".claude.json")
proj = os.getcwd()
d = json.load(open(cfg))
p = d.setdefault("projects", {}).setdefault(proj, {})
p["hasClaudeMdExternalIncludesApproved"] = True
p["hasClaudeMdExternalIncludesWarningShown"] = True
json.dump(d, open(cfg, "w"), indent=2)
print("approved external includes for", proj)
EOF
```

Scope this to the single project entry. Do not enable it globally, and never enable it for a project whose
instruction file you have not read — external includes let a repository pull arbitrary local files into your
context, which is precisely the vulnerability referenced above.

**Additional directories (declare intent, but do not rely on it alone).** Alongside the approval flag,
declare the external directory explicitly:

- `--add-dir <resolved-target-dir>`, or a persistent `permissions.additionalDirectories` entry in settings.
- From Claude Code v2.1.20, `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` makes instruction files in
  `--add-dir` directories load too.

Point these at the **resolved** target, not the symlink. This states the intent ("this outside directory
is part of my workspace") through a supported mechanism and may prove more durable across harness updates.
**However, it has been observed NOT sufficient by itself** (field report 05-09-2026, a symlinked
org-scoped install): with `additionalDirectories` correctly set, imports still did not resolve until the
per-project `hasClaudeMdExternalIncludesApproved` was set to `true`. So set **both**, and confirm with a
Check-3 probe — never assume either one alone did the job.

### Verify

Re-run the Check 3 probe. Every Tier 1 file should now appear by path. Then confirm the content is really
there, not just the filename:

```bash
claude -p "Do NOT use tools. From system context only, yes/no: does your context contain the string \
'<a distinctive string from the END of your largest Tier 1 file>'?" < /dev/null
```

Probing a string from the **tail** of the largest file tests loading *and* truncation in one shot.

Your own already-running session will still be missing the imports — the fix applies from the next fresh
start. Until then, read Tier 1 files explicitly on `readmem`, and tell the user you are doing so.

### Known upstream reports

- [claude-code#15124](https://github.com/anthropics/claude-code/issues/15124) — `@` references to files
  outside the project directory expand to the path but not the contents. Exactly this symptom; **closed as
  not planned**, so do not wait for a fix.
- [claude-code#1045](https://github.com/anthropics/claude-code/issues/1045) — feature request for
  CLAUDE.md imports across symlinked directory structures.
- [claude-code#1321](https://github.com/anthropics/claude-code/issues/1321) — related confusion in
  monorepos about which imports count as external.
- Symlink-import advisory: [tego.ai writeup](https://www.tego.ai/blog/a-hidden-project-link-can-make-claude-code-silently-send-your-files-to-an-attacker),
  [cybersecuritynews](https://cybersecuritynews.com/claude-code-symlink-import-malicious-repositories/) —
  the pre-resolution-path classification that explains both the old silent-load behaviour and the current
  silent-refusal behaviour.

**Timeline of the behaviour change** (assembled 04-09-2026; each line marked verified or inferred):

| Date | Event | Status |
|------|-------|--------|
| 23-12-2025 | [#15124](https://github.com/anthropics/claude-code/issues/15124) opened: `@` imports with openly-external (absolute) paths expand to the literal path, contents not loaded (CC 2.0.76). **Closed 14-02-2026 as "not planned"** — dropping unapproved external imports is intended behaviour, not a bug awaiting a fix. | public record |
| 18–20-07-2026 | Researcher reports the symlink bypass to Anthropic (HackerOne): internal-*looking* symlinked imports loaded **without** the external-import dialog on `2.1.207`/`2.1.215`. Anthropic closes it in two days as **"Informative" / out of scope** ("workspace trust is the boundary") — explicitly declining remediation. | public record |
| 21-07-2026 | Public disclosure (tego.ai article above). | public record |
| between 21-07 and 26-08-2026 | The flip: symlink-resolved external imports go from silently *loaded* to silently *dropped* when external-include approval is absent. **No changelog entry announces it** (checked 2.1.170–2.1.255). Whether this was a quiet reversal prompted by the disclosure or an independent hardening is **not publicly documented**. | inferred from the two brackets |
| 26-08-2026 | Silent drop verified first-hand on `2.1.246` (the investigation this document records): imports dropped with `hasClaudeMdExternalIncludesApproved: false`, loading restored by setting it. | verified (this doc) |
| 28-08-2026 | `2.1.251` ships a documented hardening cluster on adjacent symlink surfaces (file tools, plugins, workflow paths). | public record |

Two takeaways: (1) Anthropic formally declined the report, then the behaviour changed anyway within
weeks, unannounced — this code path moves silently; re-verify after every CLI upgrade. (2) The
"not planned" closure of #15124 means the drop-without-approval behaviour is *intended* — the
load-check and the external-includes approval (with additional-directories declared alongside) are permanent infrastructure, not workarounds
awaiting an upstream fix.

### If the approval flag does not fix it

1. **Dangling symlink.** `ls -l <collab_dir>` and `readlink -f <collab_dir>`; confirm the target exists. A
   moved or not-yet-cloned shared-knowledge repo produces the same silent-empty symptom.
2. **`.collab-config` points elsewhere.** Confirm `collab_dir` matches the actual directory and that the
   marker file `.collab-memory-system` is present inside the memory directory.
3. **Import paths.** Confirm each `@` path resolves from the instruction file's own location (relative
   imports resolve relative to the importing file, not the cwd), and that the block sits between the
   `<!-- collab-memory-system:start -->` / `:end` markers.
4. **Additional-directories route.** See the supported alternative above.
5. **Last resort — remove the symlink from the equation.** Replace it with a real directory inside the
   project, or run the CLI from a directory containing both project and knowledge repo. This trades away
   the shared-repo pattern; treat as a workaround and record why.

---

## Not a cause — oversized Tier 1 files

Recorded so it does not get re-derived as a theory.

It is tempting to blame missing Tier 1 content on a size budget: agent CLIs do impose limits on injected
instruction content, and an installed build can be shown to compute one. **This was tested and ruled out on Claude Code 2.1.246.**
On a set totalling ~750 KB (single files up to 200 KB), every file loaded once the approval was granted, and
probes for strings from the **tail** of the two largest files came back present — no truncation.

Two lessons worth carrying:

- **Do not infer truncation from the existence of a limit in the implementation.** Limits often apply to a
  different content channel than the one you are debugging. Test the behaviour: probe for a distinctive
  string from the *end* of the largest Tier 1 file.
- An oversized Tier 1 set is still worth fixing — it consumes context every turn and dilutes attention — but
  that is a **quality** argument for `maintainmem` (and for honouring `tier_1_max_chars`), *not* a
  correctness one. Be clear about which argument you are making; conflating them sends the user to fix the
  wrong thing.

---

## Note — duplicate installs (two or more hook blocks at session start)

**Symptom.** The collabmem methodology marker (`COLLABMEM-MARKER-` joined with `METHODOLOGY`) appears
more than once in your context, or the session-start output contains more than one collabmem hook
block. The hook blocks may be identical, or differ — e.g. an old *"Tier 1 files loaded via imports"*
line next to the newer *"should be loaded at this point. Verify"* block, which additionally tells you
the installs are on different versions. (Unlike `context.md`, `methodology.md` is never
cross-imported, so a second methodology marker always means a second install.)

**What it means.** More than one collabmem install is active in this session, all importing the
same memory — typically a **user-level** install (`~/.claude/CLAUDE.md` + `~/.claude/hooks/`) left in
place next to a later **project-level** one. The memory is then in context more than once, every
hook fires, and the installs drift apart over time (one gets upgraded, the other does not). This is a
faulty install, not a supported layout: the fix is to **remove the redundant install**, not to bring
the older one up to date (that only makes the blocks identical while the duplication stays).

**Fix.** Ask the user which install to keep. Project-level is preferred; a user-level install is fine
if it is the *only* one and the user wants it that way. Then uninstall the other one — instruction-file
import block and hook only, following the methodology's Uninstallation section; never touch the shared
memory directory, which both installs point at. Do this only with the user's explicit decision. Run the
Check 3 probe afterwards to confirm the remaining install loads.

---

## Note — multiple collabmem installs imported into one session

Setups that import more than one install's Tier 1 files (e.g. an organisation-level and a
project-level collabmem, cross-imported) put the same marker tokens into context more than once. A
marker being present therefore does not by itself prove that a *specific* install's import worked —
another install's copy of the same file may have provided it. The load-check covers this: for each
imported copy of a marker-carrying file, verify that file's marker appears in your context (see the
COLLABMEM-LOAD-CHECK section). When it is unclear which install a marker came from, the Check 3 probe
is authoritative: ask it for the exact file paths whose contents are present.

---

## Issue 2 — The session-start hook reports an error

A hook that does its job but exits non-zero produces a startup error banner (often worded as *non-blocking*).
Read the message before blaming collabmem:

- If the reported output belongs to a *different* tool (a server starting, an unrelated script), the failing
  hook is not the collabmem hook — multiple hooks can register for the same event across project-level and
  user-level settings. Check both.
- collabmem hooks are identifiable by the `collab-memory-` name prefix.
- For a hook that behaves correctly but exits non-zero, inspect its exit path — a trailing command whose
  status becomes the script's status is the usual cause.

A failing session-start hook does **not** by itself prevent Tier 1 imports from loading; these are separate
mechanisms. Diagnose them independently rather than assuming one caused the other.

---

## Issue 3 — The instruction file itself did not load

The layer below Issue 1: not the imports, but the instruction file
(`CLAUDE.md`-equivalent) carrying them never reached context. Detected by the
session-start hook's check a): the COLLABMEM-LOAD-CHECK section is absent.

### Symptoms

- No COLLABMEM-LOAD-CHECK section anywhere in context; typically no Tier 1
  content either.
- The hook may still have fired (hook execution and instruction-file loading
  are separate mechanisms — see Issue 2). If the hook did NOT fire either,
  the most likely explanation is that the session was started in a different
  directory than the project root: both the hook configuration
  (`.claude/settings.json`) and the instruction file are found relative to
  the session's root, so a wrong root makes both vanish at once — silently.

### Causes and fixes

1. **Session rooted at the wrong directory.** The instruction file loads from
   the session's project root. Verify the working directory matches the
   project. In the **native desktop app**, the session binds to a folder via
   the **working-directory chip** in the composer (the folder-name chip →
   Recent / "Open folder…") — note the folder-with-`+` chip only *adds* a
   directory, it does not switch the session root; using it by mistake leaves
   the session rooted elsewhere. (Verified on Claude 1.30096.5, 2026-08-14;
   UI details are version-specific.)
2. **Instruction file missing or misplaced.** Confirm the file exists at the
   project root (or `.claude/CLAUDE.md`) and contains the
   `<!-- collab-memory-system:start -->` block.
3. **Verify like Issue 1:** the fresh non-interactive probe (Check 3) from the
   correct directory answers decisively what the harness loads.

---

## Technique — investigating harness behaviour

When a memory problem looks like harness behaviour, resist answering from recollection. In order:

1. **Observable-behaviour test.** The fresh non-interactive probe (Check 3) answers "what does the harness
   actually put in context?" directly, and stays valid across versions.
2. **Search the public record.** Issue tracker, release notes, advisories. This is where you learn *why the
   behaviour changed* — the one thing local inspection cannot tell you. Do this early: skipping it is how
   you end up with a fix that works and an explanation that is wrong.
3. **Inspect the installed build, only for the remaining "why".** Locating a config key or gating condition
   in the shipped bundle can turn a guess into a mechanism:

   ```bash
   strings -a "<path to installed CLI binary/bundle>" | grep -a -o -E ".{200}<keyOrMessage>.{200}"
   ```

   Useful for confirming a config key still exists under that name, and for finding the user-facing string
   of a dialog you expected but never saw. Treat findings as **unofficial and version-specific**; label them
   as inferred, and never let them override observed behaviour.

Distinguish verified from inferred when you report. "The flag was false and setting it restored loading" is
verified. "Classification uses the pre-resolution path" is a mechanism — here corroborated by public
advisories, which is what promoted it from guess to explanation.

---

## Prevention

- **Re-run the probe after any CLI upgrade, config-directory change, machine change, or project move.**
  These are the events that change or reset external-import handling.
- **Spot-check at session start that Tier 1 is actually present** — confirm you can see current-work content
  without opening a file. If you cannot, say so immediately and offer to fix it; point the user at this
  document. Do not silently read the files instead.
- **Record the specifics in `world/how-tos.md`** once diagnosed for a setup: config file path, flag name,
  probe command. Turns a multi-hour investigation into a one-minute check next time.
- **Write the episodic note** when you fix an instance. The failure is invisible enough that future sessions
  will otherwise rediscover it from scratch.

---

## Escalating

If the problem is in collabmem itself — methodology, templates, hooks, or installation procedure — do not
improvise changes to system files (methodology §15). File an issue:

**https://github.com/visionscaper/collabmem/issues**

Include: what you were trying to do, what happened, what you expected, the methodology version from
`.collab-memory-system`, platform and CLI version, the installation layout (symlinked shared-knowledge repo
or in-project directory), and any error text. For loading failures, include the Check 3 probe output — the
single most useful artefact.

**Report back — especially when you found the solution.** If you diagnosed and
fixed an instance of any issue in this document (or one it does not cover),
propose to the user to file a short issue at
https://github.com/visionscaper/collabmem/issues describing the symptom, the
environment (CLI + version, install pattern), and what fixed it. A solved case
is the most valuable report there is — it is how this document and the system
improve. Filing an issue is deliberately low-effort; a PR from a fork with the
fix is welcome too, but never required.

---

*Written with AI assistance (Claude). Review before distribution.*
