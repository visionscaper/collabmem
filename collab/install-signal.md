### The install signal

This is the procedure for the install signal: asking the user whether you may send the collabmem developers one small, anonymous signal that says a collabmem install or upgrade happened.

The signal tells the developers which collabmem setups, AI clients and operating systems are in use, so they know what to support. It also lets them show that collabmem is really used.

The signal must only be sent after the user has said yes. The user sees every value before it is sent.

Every person who uses collabmem is asked for themselves. When the answer is no, the install signal is never asked for again.

**One question, one attempt, then it is over.** That holds for the asking and for the sending.

#### The procedure in short

1. **Get the install ID.** It is a random number that stands for this install. Without one there is no signal, and nothing is asked.
2. **Collect the values:** the collabmem version, the setup, the AI client and model, and the operating system.
3. **Ask the user,** with a message that lists the values. A person who agreed before gets a shorter question at an upgrade.
4. **On a yes, send the signal,** with one `curl` command. When that does not work, show the same values as a link.
5. **Record the answer** in the user's personal file.

The procedure is used in three situations. Each has its own kind of signal:

- **At the end of an installation.** The kind is `install`, or `team_member` in a distributed setup.
- **At the end of an upgrade.** The kind is `upgrade`.
- **In a normal session, when the session-start hook reports the signal as pending.** That is for a person who was not asked by an installation or an upgrade. The section "When the session hook reports the signal as pending" says which kind applies.

#### The install ID

The install ID is kept in the memory directory, in the file `<collab>/.install-id`: one line, the ID. The memory directory is shared by exactly the people who work with this install, so they all send the same install ID.

If that file exists, use the ID in it.

Otherwise make a new random UUID with a tool that is already on the machine, and write it to `<collab>/.install-id` right away, whatever the user will answer. For example:

- `uuidgen` on macOS and most Linux systems.
- `cat /proc/sys/kernel/random/uuid` on Linux.
- `[guid]::NewGuid().ToString()` in PowerShell on Windows.

**If you cannot make an install ID**, skip the install signal completely. Do not ask the question and record nothing.

A new `.install-id` file is part of the memory. Commit it with the memory, in the way the procedure that sent you here describes.

#### The values of the signal

The signal consists of the values below. Each has a name, and the rest of this procedure uses these names.

- `signal_kind`: what happened. One of:

  - `install`: a new install in a solo or a standalone setup.
  - `team_member`: a person starts to work with an install that is shared.

    - In a distributed setup a team shares the memory, and everyone who installs is a member of that team, also the first one. So such a project sends only `team_member` signals at an install.
    - In a solo or a standalone setup the project can be shared too. A person who joins an install that someone else made sends `team_member`.
  - `upgrade`: an existing install got a new version. This holds for every person, also for a team member.

- `collabmem_version`: the version in `<collab>/.collab-memory-system`, without the leading `v`. For example `1.8.7`.

- `setup`: how collabmem is set up in this project. One of:

  - `solo`: the memory lives inside the code repository.
  - `standalone`: there is no code repository; the memory repository is the project.
  - `distributed`: the memory lives in a separate shared-knowledge repository.

- `client`: the name of the AI client you run in. For example `claude-code`.

- `client_version`: the version of that client. For example `2.1.263`.

- `client_type`: how the user works with the client. One of `terminal`, `native`, `web`, `ide`, or `unknown`. `native` is a desktop app.

- `model`: the AI model you are. Use the identifier of the model when you know it, for example `claude-opus-5-5`; otherwise its name.

- `os`: the operating system. One of `macos`, `linux`, `windows`, or `unknown`.

- `os_version`: the version of the operating system. For example `15.5`.

- `install_id`: the install ID of the section above.

One more name is used in the message to the user. **It is not sent.**

- `signal_event`: what the message says that happened. It depends on `signal_kind`:

  - For `install`: "a collabmem install happened".
  - For `team_member`: "a new team member started using collabmem".
  - For `upgrade`: "a collabmem upgrade happened".

#### Collecting the values

Collect the values before you ask, because the user sees them in the question.

**Collecting should cost the user nothing.** Use what you know already, or what one simple command prints. Otherwise the value is `unknown`.

- Do not ask the user for a value.
- Do not do exhaustive searches.
- Install nothing to get a value.
- Do not guess.

**The values allow very little freedom.** The endpoint accepts a signal only when every value has exactly the form below. It ignores any other signal, and it does not say so: neither you nor the user would notice.

- `signal_kind`, `setup`, `client_type` and `os`: exactly one of the words listed above, in lower case.
- `collabmem_version`: digits and dots, with at most one lower-case letter at the end. For example `1.8.7` or `1.8.5a`.
- `client`: lower-case letters, digits and dashes only, at most 32 characters, or `unknown`.
- `model`: the identifier or the name of the model and nothing else, at most 64 characters, or `unknown`. Only letters, digits, spaces, dots, dashes, colons and slashes. It starts with a letter or a digit.
- `client_version` and `os_version`: they start with a digit. After that only letters, digits, dots, dashes, underscores and plus signs, at most 32 characters. A version in another form becomes `unknown`.
- `install_id`: exactly as the tool made it, or as it stands in `<collab>/.install-id`.

#### When the session hook reports the signal as pending

This section is only for the third situation: the session-start hook reports the signal as pending. At an installation or an upgrade you do not need it. There the installation or upgrade instructions say which kind of signal applies and when to ask.

The hook reports it for a person who was not asked by an installation or an upgrade. For example a team member who received collabmem, or a new version of it, through a plain `git pull`.

**Which kind to send.** The hook's message says which of the two it is.

- **This person's first signal for this project:** the `signal_kind` is `team_member`, in every setup. The install existed before this person was asked, so they joined it. Use the full message of "How to ask".
- **This person agreed to a signal before, and collabmem was upgraded to a new version since:** the `signal_kind` is `upgrade`. Use "The short ask, for a later upgrade".

**When to ask.** The hook's message says this too. There are two moments.

- **Together with a message from the developers.** That is the normal case. The welcome, or the message that collabmem was upgraded, comes first in your response and thanks the user. The question comes at the end of that same response. The hook's message gives the layout.
- **After the next memory update.** This happens only when the question was asked together with a message and got no answer. It is asked this one more time, and that is the last time.

  - There is no message from the developers in front of it now, so open warmly yourself. For example: "Thanks for using collabmem! Its developers have one quick question for you."
  - Say that a clear yes or no is fine either way.
  - If the user leaves it unanswered again, record `declined`.

#### How to ask

Render the message below verbatim, as a message from the collabmem developers. Fill in the placeholders with the values you collected. Change nothing else.

> "We'd like to understand what type of collabmem setup you use, so we can keep supporting you in the best way. It also helps us show that collabmem is really used.
>
> May your AI send us one small signal that says `<signal_event>`? **It is anonymous: it says nothing about you or your project.** This is all it contains:
>
> - collabmem version: `<collabmem_version>`
> - Setup: `<setup>`
> - AI client: `<client>` `<client_version>`, used in the `<client_type>` client
> - AI model: `<model>`
> - Operating system: `<os>` `<os_version>`
> - A random number, so that we count this install once: `<install_id>`
>
> To block fake signals, we keep a scrambled form of your network address for a limited time, then erase it. Apart from that, we store nothing that could identify you, and we do not track you."

Then give the user two plain options to answer with: yes, or no thanks. Wait for the answer.

#### The short ask, for a later upgrade

Use the short ask only for an upgrade signal, and only when the user's recorded answer for this project is `sent` or `failed`: they agreed to the signal before. "Recording the answer" below says where that answer is kept.

Ask in your own words whether you may send the upgrade signal to the collabmem developers. Show the same list of values as in the message of "How to ask", and offer to repeat what the signal is about. For example:

> "May I send the upgrade signal to the collabmem developers? This is all it contains:
>
> `<the same list of values>`
>
> I can repeat what this is about, if you like."

When the user wants to hear what it is about, render the full message from "How to ask".

#### When the user says yes: sending the signal

Send the values with the `curl` command, as a `POST`. Fill in every placeholder.

```bash
curl --silent --max-time 5 \
  --user-agent "collabmem-agent/<collabmem_version>" \
  --data-urlencode "kind=<signal_kind>" \
  --data-urlencode "install_id=<install_id>" \
  --data-urlencode "version=<collabmem_version>" \
  --data-urlencode "setup=<setup>" \
  --data-urlencode "client=<client>" \
  --data-urlencode "client_version=<client_version>" \
  --data-urlencode "client_type=<client_type>" \
  --data-urlencode "model=<model>" \
  --data-urlencode "os=<os>" \
  --data-urlencode "os_version=<os_version>" \
  https://signals.lucens.ai/collabmem
```

Keep the names before each `=` and the `--user-agent` text as they are. In PowerShell on Windows, call the command as `curl.exe`: plain `curl` is another command there.

**The signal arrived when the answer is exactly `Signal received, thank you!`.** Tell the user in one line that the signal was received, and that the collabmem developers say thank you.

**Any other outcome means it did not arrive.** For example: no answer, an error, a page from a proxy, or no `curl` command on the machine. Show the user the same values as a link:

> "The signal could not be sent from here. Please click this link to send it manually, or copy it into the address bar of your browser:"
>
> `https://signals.lucens.ai/collabmem?kind=<signal_kind>&install_id=<install_id>&version=<collabmem_version>&setup=<setup>&client=<client>&client_version=<client_version>&client_type=<client_type>&model=<model>&os=<os>&os_version=<os_version>`

Percent-encode each value in the link: a space in a model name becomes `%20`.

#### Recording the answer

The answer belongs to the person, not to the project. So it is not kept in the project or in the memory, but in the user's personal collabmem file, `~/.config/collabmem/personal.ini`. That file has one section per project, named by the path of the project root. Two values in the section of this project record the answer:

- `signal`: what happened.

  - The signal arrived → `sent`
  - The user said yes, and the signal did not arrive → `failed`
  - The user said no → `declined`

- `signal-version`: the `collabmem_version` the user was asked for, at an install or at an upgrade. It tells a later upgrade, and the session hook, that this person has been asked for this version already.

Write both with these commands, run in the project root. Put the values in place of `<answer>` and `<collabmem_version>`.

```bash
mkdir -p ~/.config/collabmem
git config --file ~/.config/collabmem/personal.ini "project.$(pwd -P).signal" <answer>
git config --file ~/.config/collabmem/personal.ini "project.$(pwd -P).signal-version" <collabmem_version>
```

**If the file cannot be written,** for example because the session may not write outside the project: tell the user that the answer could not be saved, and what that means. collabmem cannot remember it, so they may be asked again. Offer to help fix it; Issue 4 of the troubleshooting guide, `<collab>/docs/troubleshoot.md`, has the usual causes. When the session's own settings are what blocks it, those settings have to allow this one file. As a last resort, show the commands and ask the user to run them themselves.

To read what is recorded, run these in the project root. Each prints nothing when there is no value yet.

```bash
git config --file ~/.config/collabmem/personal.ini --get "project.$(pwd -P).signal"
git config --file ~/.config/collabmem/personal.ini --get "project.$(pwd -P).signal-version"
```

#### When the user asks for more

You can tell the user the following, in your own words.

- The signal goes to a small endpoint run by the collabmem developers. It stores the values shown in the question, the time the signal arrived, and whether it was counted.
- The network address itself is never stored. Only a scrambled form is kept, for a limited time, to recognise fake and repeated signals. After that it is erased.
- There is no account and no cookie, and nothing is sent later without a new question.
- Saying no changes nothing about how collabmem works.
