### The install signal

This is the procedure for the install signal: asking the user whether you may send the collabmem developers one small, anonymous signal that says a collabmem install or upgrade happened.

The signal tells the developers which collabmem setups, AI clients and operating systems are in use, so they know what to support. It also lets them show that collabmem is really used.

The signal must only be sent after the user has said yes. The user sees every value before it is sent.

#### The values of the signal

The signal consists of the values below. Each has a name, and the rest of this procedure uses these names.

- `signal_kind`: what happened. One of:

  - `install`: a new install in a solo or a standalone setup.
  - `team_member`: a new install in a distributed setup. In a distributed setup a team shares the memory, and everyone who installs is a member of that team, also the first one. So such a project sends only `team_member` signals.
  - `upgrade`: an upgrade of an existing install.

- `signal_kind_word`: the word for `signal_kind` in the message to the user. It is `upgrade` when `signal_kind` is `upgrade`, and `install` otherwise. It is not sent.

- `collabmem_version`: the version in `<collab>/.collab-memory-system`, without the leading `v`. For example `1.8.7`.

- `setup`: how collabmem is set up in this project. One of:

  - `solo`: the memory lives inside the code repository.
  - `standalone`: there is no code repository; the memory repository is the project.
  - `distributed`: the memory lives in a separate shared-knowledge repository.

- `client`: the name of the AI client you run in. For example `claude-code`.

- `client_version`: the version of that client. For example `2.1.263`.

- `client_type`: how the user works with the client. One of `terminal`, `native`, `web`, `ide`. `native` is a desktop app.

- `os`: the operating system. One of `macos`, `linux`, `windows`.

- `os_version`: the version of the operating system. For example `15.5`.

- `install_id`: a random number that stands for this install. See "The install ID" below.

#### Collecting the values

Collect the values before you ask, because the user sees them in the question.

- Do not ask the user for a value.
- Read a value only when one simple command gives it, or when you know it already. Do not search for it.
- Install nothing to get a value.
- Do not guess. When you cannot read `client`, `client_version`, `client_type`, `os` or `os_version`, its value is `unknown`.

**The values allow very little freedom.** The endpoint accepts a signal only when every value has exactly the form below. It ignores any other signal, and it does not say so: neither you nor the user would notice.

- `signal_kind`, `setup`, `client_type` and `os`: exactly one of the words listed above, in lower case.
- `collabmem_version`: digits and dots, with at most one lower-case letter at the end. For example `1.8.7` or `1.8.5a`.
- `client`: lower-case letters, digits and dashes only, at most 32 characters.
- `client_version` and `os_version`: they start with a digit. After that only letters, digits, dots, dashes, underscores and plus signs, at most 32 characters. A version in another form becomes `unknown`.
- `install_id`: exactly as the tool made it, or as it stands in `<collab>/.install-id`.

#### The install ID

The install ID is kept in the memory directory, in the file `<collab>/.install-id`: one line, the ID. The memory directory is shared by exactly the people who work with this install, so they all send the same install ID.

If that file exists, use the ID in it.

Otherwise make a new random UUID with a tool that is already on the machine, and write it to `<collab>/.install-id` right away, whatever the user will answer. For example:

- `uuidgen` on macOS and most Linux systems.
- `cat /proc/sys/kernel/random/uuid` on Linux.
- `[guid]::NewGuid().ToString()` in PowerShell on Windows.

The install ID is derived from nothing: not from a name, a path or the machine.

**If you cannot make an install ID**, skip the install signal completely. Do not ask the question and record nothing.

A new `.install-id` file is part of the memory. Commit it with the memory, in the way the procedure that sent you here describes.

#### How to ask

Render the message below verbatim, as a message from the collabmem developers. Fill in the placeholders with the values you collected. Change nothing else.

> "We'd like to understand what type of collabmem setup you use, so we can keep supporting you in the best way. It also helps us show that collabmem is really used.
>
> May your AI send us one small signal that says a collabmem `<signal_kind_word>` happened? **It is anonymous: it says nothing about you or your project.** This is all it contains:
>
> - collabmem version: `<collabmem_version>`
> - Setup: `<setup>`
> - AI client: `<client>` `<client_version>`, used in the `<client_type>` client
> - Operating system: `<os>` `<os_version>`
> - A random number, so that we count this install once: `<install_id>`
>
> To block fake signals, we keep a scrambled form of your network address for a limited time, then erase it. Apart from that, we store nothing that could identify you, and we do not track you."

Then give the user two plain options to answer with: yes, or no thanks. Wait for the answer.

#### The short ask, for a later upgrade

Use the short ask only at an upgrade, and only when the user's recorded answer for this project is `sent` or `failed`: they agreed to the signal before. "Recording the answer" below says where that answer is kept. It leaves out the reasons, and keeps the list of values.

Ask in your own words whether you may send the upgrade signal to the collabmem developers. Show the same list of values as in the message above, and offer to repeat what the signal is about. For example:

> "May I send the upgrade signal to the collabmem developers? This is all it contains:
>
> - collabmem version: `<collabmem_version>`
> - Setup: `<setup>`
> - AI client: `<client>` `<client_version>`, used in the `<client_type>` client
> - Operating system: `<os>` `<os_version>`
> - A random number, so that we count this install once: `<install_id>`
>
> I can repeat what this is about, if you like."

When the user wants to hear what it is about, render the full message from "How to ask".

#### When the user says yes: sending the signal

Send the values once, with the `curl` command, as a `POST`. Fill in every placeholder.

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
  --data-urlencode "os=<os>" \
  --data-urlencode "os_version=<os_version>" \
  https://signals.lucens.ai/collabmem
```

Keep the names before each `=` and the `--user-agent` text as they are. In PowerShell on Windows, call the command as `curl.exe`: plain `curl` is another command there.

**The signal arrived when the answer is exactly `Signal received, thank you!`.** Tell the user in one line that the signal was received, and that the collabmem developers say thank you.

**Any other outcome means it did not arrive.** For example: no answer, an error, a page from a proxy, or no `curl` command on the machine. Do not try again. Show the user the same values as a link, once:

> "The signal could not be sent from here. Please click this link to send it manually, or copy it into the address bar of your browser:"
>
> `https://signals.lucens.ai/collabmem?kind=<signal_kind>&install_id=<install_id>&version=<collabmem_version>&setup=<setup>&client=<client>&client_version=<client_version>&client_type=<client_type>&os=<os>&os_version=<os_version>`

Do not ask whether the user clicked it.

#### Recording the answer

The answer belongs to the person, not to the project. So it is not kept in the project or in the memory, but in the user's personal collabmem file, `~/.config/collabmem/personal.ini`. That file has one section per project, named by the path of the project root. The answer is the value `install-signal` in the section of this project.

Write it with this command, run in the project root. Put the value in place of `<answer>`.

```bash
mkdir -p ~/.config/collabmem && git config --file ~/.config/collabmem/personal.ini "project.$(pwd -P).install-signal" <answer>
```

- The signal arrived → `sent`
- The user said yes, and the signal did not arrive → `failed`
- The user said no → `declined`

None of these leads to a second attempt.

If the file cannot be written, for example because the session may not write outside the project, tell the user in one line that the answer could not be saved, and go on.

To read the recorded answer, run this in the project root. It prints nothing when there is no answer yet.

```bash
git config --file ~/.config/collabmem/personal.ini --get "project.$(pwd -P).install-signal"
```

#### When the user asks for more

You can tell the user the following, in your own words.

- The signal goes to a small endpoint run by the collabmem developers. It stores the values shown in the question, the time the signal arrived, and whether it was counted.
- The network address itself is never stored. Only a scrambled form is kept, for a limited time, to recognise fake and repeated signals. After that it is erased.
- There is no account and no cookie, and nothing is sent later without a new question.
- Saying no changes nothing about how collabmem works.
