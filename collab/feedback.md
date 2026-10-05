### feedbackmem — Feedback to the collabmem Developers

This is the `feedbackmem` procedure: helping the user send short, private feedback about collabmem to its developers, by mail. Also when the user types `feedbackmem` themselves, run this procedure.

The developers cannot foresee and test every situation collabmem is used in. Feedback from real use is how they learn what does not work. You draft the mail, the user reads and approves it, and the user sends it.

#### When to suggest it

Suggest feedback when one of these happened:

- **During an install or an upgrade:** a step failed and needed a workaround; the procedure could not be completed; or collabmem could not be fitted into the user's existing workflow or memory setup.
- **During normal use:** the user shows frustration about how collabmem behaves; the same problem with the memory system happens a second time; or an instruction of the methodology turns out to be wrong, contradictory or impossible to follow.
- **The user has a suggestion** for collabmem.

Keep it from becoming a nuisance:

- Never interrupt the work for it. Suggest it when the task at hand is finished, or at a memory update.
- Suggest it at most once per issue.
- After a no, do not suggest it again in this session.
- Do not suggest it at all when the user has switched the suggestions off. This command prints `off` in that case, and nothing otherwise:

  ```bash
  git config --file ~/.config/collabmem/personal.ini --get collabmem.feedback-suggestions
  ```

When the user types `feedbackmem`, none of these limits apply: go straight to "Drafting the mail".

#### How to suggest it

Say in one or two sentences what happened, and offer to write short feedback about it to the collabmem developers. Then tell the user these three things, in plain words:

- The feedback is about collabmem only. It contains no details of what they were working on.
- It goes by mail, from their own mail address. So the developers see that address and can reply.
- You prepare the mail as a draft. They read it, and they are the one who sends it.

Give two plain options to answer with: yes, or not now.

**After a "not now":** leave it. You may add, once, that you can stop suggesting this altogether if they prefer. If they say so, record it:

```bash
mkdir -p ~/.config/collabmem && git config --file ~/.config/collabmem/personal.ini collabmem.feedback-suggestions off
```

#### Drafting the mail

**What stays out.** No proprietary details of the user's work: no file names, code, project names, data or business matters. No personal details. Describe the work in general terms, such as "writing code" or "discussing options". If a detail of that kind is needed to understand the issue, ask the user explicitly whether it may go in, and add it only after a yes.

**Keep it short:** at most about 180 words, which is about 1200 characters. A longer mail may not open as a draft.

**The subject:**

```
collabmem: <kind>: <short title>
```

The `<kind>` is `blocking issue`, `non-blocking issue` or `suggestion`. An issue is blocking when the user could not go on with collabmem because of it.

**The text.** Leave out a part that has nothing in it.

```
Hello,

<Summary: one or two lines that say what this is about.>

Context
- Experience with collabmem: <first-time user | has used it for a while | very experienced user>. Installed since <month and year>, about <number> notes.
- What we were doing: <in general terms>
- Step: <for an install or an upgrade: the document and the step in which it happened>

<"The issue" or "The suggestion">
<For an issue: what was expected, what happened, and what was tried and whether it helped.>
<For a suggestion: the idea, and what it would improve.>

Details
- collabmem version: <version>
- Setup: <solo | standalone | distributed>
- AI client: <name> <version>, used in the <terminal | native | web | ide> client
- AI model: <the identifier or the name of the model>
- Operating system: <macos | linux | windows> <version>

Questions to the developers
<Questions the user or you have for them.>

This mail was drafted by my AI assistant and approved by me.
```

Where the values come from:

- The collabmem version is in `<collab>/.collab-memory-system`.
- "Installed since" is the date of the oldest entry in the Episodic Memory Index, including `index-archive.md`. The number of notes is the number of entries, rounded.
- Use `unknown` for a detail you cannot read. Do not guess, and do not ask the user for it.
- Never put the install ID in the mail.

#### Showing the draft and asking

Show the user the subject and the whole text, exactly as they will be sent. Then ask two things in the same message:

1. Whether the draft is right, or what they want changed.
2. Where they read their mail: in a mail program on this computer, or in the browser.

Change the draft until the user approves it. Nothing leaves the machine before that.

#### Getting the mail to the user

**A mail program on this computer.** Open the mail as a draft with a `mailto:` link. Tell the user first that a draft will open in their mail program, and that they press send themselves.

Build the link like this, with the subject and the text percent-encoded: a space becomes `%20`, a line break becomes `%0A`, and every other character that is not a letter or a digit is encoded as well.

```
mailto:feedback@lucens.ai?subject=<encoded subject>&body=<encoded text>
```

Open it with the command of the operating system:

```bash
open "<link>"              # macOS
xdg-open "<link>"          # Linux
start "" "<link>"          # Windows, in cmd; in PowerShell: Start-Process "<link>"
```

Then ask whether the draft opened. If it did not, go on with the next case.

A mail program may add the user's own signature under the text, with their name or phone number. Mention that they can remove it before sending if they prefer.

**Mail in the browser, or the draft did not open.** The user pastes the mail themselves.

- Put the text on the clipboard, with a tool that is already on the machine: `pbcopy` on macOS, `Set-Clipboard` in PowerShell on Windows, `wl-copy` or `xclip` on Linux. Install nothing for this. Without such a tool, show the text again for copying.
- Show the address and the subject as two short lines:

  ```
  To: feedback@lucens.ai
  Subject: <subject>
  ```

- Tell the user: start a new mail, fill in these two lines, and paste the text.

In both cases, end by thanking the user in one line. Do not ask afterwards whether they sent it.

#### The public route

A user who prefers to report in public can file an issue at https://github.com/visionscaper/collabmem/issues. Offer to help draft it. The same rule holds there: no proprietary details and no personal details.
