#!/bin/bash
#
# collab-memory-hook.sh — Lifecycle hook for the Collaboration Memory System
# collabmem hook, checked and updated up to: v1.8.6
#
# Handles two Claude Code hook events:
#   - SessionStart: Context recovery, health check, and memory triggers
#   - UserPromptSubmit: Timestamp
#
# Install by adding to .claude/settings.json (see install.md Step 6 for the configuration).
# The script reads .collab-config from the project root for the collab directory path.
#

set -e

# Read hook input from stdin
INPUT=$(cat)

# Extract a flat string field from the hook's JSON input without depending on
# jq (absent on macOS before Sequoia and on many Linux installs). The fields
# we need are simple strings set by the harness; first match wins. Quotes
# inside JSON strings are always escaped (\"), so user text cannot spoof a key.
json_field() {
    printf '%s' "$INPUT" | tr -d '\n' \
        | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n 1 \
        | sed 's/^"[^"]*"[[:space:]]*:[[:space:]]*"//; s/"$//'
}

# Extract hook event name
HOOK_EVENT=$(json_field hook_event_name)

# Read .collab-config for collab directory path
CONFIG_FILE=".collab-config"
if [ -f "$CONFIG_FILE" ]; then
    COLLAB_DIR=$(grep '^collab_dir=' "$CONFIG_FILE" | cut -d'=' -f2 || true)
fi
COLLAB_DIR="${COLLAB_DIR:-collab}"

# Timestamp
CURRENT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')

# --- Health check ---
# Verifies key memory files exist. Outputs warnings for missing files.
check_health() {
    local missing=()
    local files=(
        "$COLLAB_DIR/methodology.md"
        "$COLLAB_DIR/index.md"
        "$COLLAB_DIR/notes.md"
        "$COLLAB_DIR/world/index.md"
        "$COLLAB_DIR/world/context.md"
        "$COLLAB_DIR/world/preferences.md"
        "$COLLAB_DIR/world/state.md"
    )

    for f in "${files[@]}"; do
        if [ ! -f "$f" ]; then
            missing+=("$f")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "WARNING: Missing collaboration memory files:"
        for f in "${missing[@]}"; do
            echo "  - $f"
        done
        echo ""
    fi
}

# --- Load check ---
# Two-layer check: a) verifies the instruction file (with the COLLABMEM-LOAD-CHECK
# section) reached context; b) delegates marker verification to that section.
# The hook never asserts that files are loaded — it cannot observe that.
# Marker tokens are deliberately NOT spelled out here (single definition site =
# the COLLABMEM-LOAD-CHECK section; avoids self-match from hook output).
print_load_check() {
    echo "Tier 1 collabmem memory-system files should be loaded at this point. Verify:"
    echo ""
    echo "a) Confirm that the COLLABMEM-LOAD-CHECK section — the section of the project"
    echo "   instruction file containing the marker-verification instructions and the"
    echo "   two banner lines — is present in your context (this hook message does not"
    echo "   count)."
    echo "b) If it is present, execute the COLLABMEM-LOAD-CHECK instructions now."
    echo "c) If it is NOT present, the project instruction file (CLAUDE.md) itself did"
    echo "   not load — the collabmem memory system is not operational. Report this to"
    echo "   the user before doing anything else, starting your message with this"
    echo "   exact line:"
    echo "   ====== COLLABMEM MEMORY SYSTEM FAILED TO LOAD ======"
    echo "   Do not read the memory files as a substitute before the user has been"
    echo "   told. Offer to help resolve it; when the user agrees, start by"
    echo "   consulting the troubleshooting guide:"
    echo "   - Local: $COLLAB_DIR/docs/troubleshoot.md"
    echo "   - If the local file is unreachable or you can't find it:"
    echo "     https://raw.githubusercontent.com/visionscaper/collabmem/refs/heads/main/clients/claude-code/troubleshoot.md"
    echo "d) If the COLLABMEM-LOAD-CHECK section, the collabmem methodology marker"
    echo "   (COLLABMEM-MARKER- joined with METHODOLOGY), or this collabmem hook"
    echo "   output appears more than once in your context, then more than one"
    echo "   collabmem install is active over the same memory (occurrences that"
    echo "   appear only in a compaction summary do not count). Tell the user before"
    echo "   doing anything else, in plain language: the memory system is active"
    echo "   twice in this session, and this needs resolving, usually by removing"
    echo "   the extra copy. Ask whether they want to clean this up. If they agree,"
    echo "   discuss with them"
    echo "   which copy to remove (recommend keeping the project-level one) and"
    echo "   only then consult the \"duplicate installs\" note in the troubleshooting"
    echo "   guide (same locations as above) and remove anything. Technical detail"
    echo "   only if asked. Do not proceed as if this were a single install."
}

# --- Memory triggers ---
# Republished at session start for primacy position in context window.
# Sentinel token names create attention matches to methodology headings.
print_memory_triggers() {
    echo ""
    echo "IMPORTANT: The user may include readmem, updatemem, maintainmem, upgrademem, helpmem, starmem, or feedbackmem in their messages — when present, you MUST perform the corresponding operation."
    echo "The methodology also defines word cues and conceptual triggers for automatic memory operations."
    echo "When searching for information, check your context window for World Model Index or Episodic Memory Index entries before searching files."
}

# --- Pending questions from the collabmem developers ---
# The developers have two questions for every person who uses collabmem: the
# star ask and the install signal (see support.md and install-signal.md in
# the collab directory). The answers are personal, so they are kept in the
# user's personal collabmem file and not in the project. That file is not
# loaded into the session, so the hook reports which questions are still due
# for this person. It covers everyone who was not asked by an install or an
# upgrade procedure: for example a team member who received collabmem, or a
# new version of it, through a plain "git pull".
# Prints nothing when no question is due.

PERSONAL_FILE="$HOME/.config/collabmem/personal.ini"

# Says whether the personal file can be used: "ok", "unreadable" (it exists
# but cannot be read, or its content is damaged) or "unwritable" (it, or its
# folder, cannot be written). A file that does not exist yet is fine: it is
# made when the first value is written.
#
# This is not the same as a value that is missing. A missing value means
# "not asked yet". A file that cannot be used means we do not know, and then
# nothing may be asked.
personal_file_state() {
    if [ -e "$PERSONAL_FILE" ]; then
        git config --file "$PERSONAL_FILE" --list >/dev/null 2>&1 \
            || { echo "unreadable"; return 0; }
        [ -w "$PERSONAL_FILE" ] || { echo "unwritable"; return 0; }
    else
        mkdir -p "$(dirname "$PERSONAL_FILE")" 2>/dev/null \
            || { echo "unwritable"; return 0; }
        [ -w "$(dirname "$PERSONAL_FILE")" ] || { echo "unwritable"; return 0; }
    fi

    echo "ok"
}

# Reads one value of this project from the personal file; empty when absent.
read_personal_value() {
    [ -f "$PERSONAL_FILE" ] || return 0

    # The same path the procedures use when they write a value.
    git config --file "$PERSONAL_FILE" \
        --get "project.$(pwd -P).$1" 2>/dev/null || true
}

# The collabmem version that is installed in this project, without the "v".
installed_version() {
    sed 's/^v//' "$COLLAB_DIR/.collab-memory-system" 2>/dev/null \
        | tr -d '[:space:]' || true
}

# Says which install signal is due for this person: "first" (they have no
# signal answer yet), "upgrade" (they agreed before, and another version is
# installed now) or nothing. The signal needs the install ID of the project;
# without one there is nothing to send. A "declined" is never raised again.
due_signal() {
    local version signal
    version=$(installed_version)
    [ -f "$COLLAB_DIR/.install-id" ] && [ -n "$version" ] || return 0

    signal=$(read_personal_value signal)
    if [ -z "$signal" ]; then
        echo "first"
    elif [ "$signal" != "declined" ] \
        && [ "$(read_personal_value signal-version)" != "$version" ]; then
        echo "upgrade"
    fi
}

# Tells the AI that the personal file cannot be used, what that means, and
# what to offer the user. Printed in every new session until it is fixed.
print_personal_file_problem() {
    echo ""
    echo "PROBLEM WITH THE PERSONAL COLLABMEM FILE: $PERSONAL_FILE is $1."
    echo "In your first response of this session, tell the user, in plain words:"
    echo "- collabmem keeps a person's own settings for collabmem in that file, and the file cannot be read or written right now."
    echo "- This does not affect the functioning of the memory itself. It keeps collabmem from recording personal settings: for example the answers to the questions from its developers. So those questions are not asked, until this is fixed."
    echo "- Offer to help find out what is wrong and to fix it. Change nothing before the user agrees."
    echo "If it cannot be fixed, suggest feedback to the developers: the feedbackmem procedure."
}

print_pending_questions() {
    command -v git >/dev/null 2>&1 || return 0

    local pending=()

    # An index entry is a table row that starts with a date.
    local entries
    entries=$(grep -c '^| [0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9] ' \
        "$COLLAB_DIR/index.md" 2>/dev/null || true)
    entries="${entries:-0}"

    # The star ask. It waits until the memory has grown by at least 5
    # entries since this person had their welcome: they have seen the system
    # work by then. Counting from the welcome matters for a person who joins
    # a memory that is large already.
    local starred entries_at_welcome
    starred=$(read_personal_value project-starred)
    entries_at_welcome=$(read_personal_value entries-at-welcome)
    case "$entries_at_welcome" in
        ''|*[!0-9]*) entries_at_welcome=0 ;;
    esac
    if [ "$entries" -ge $((entries_at_welcome + 5)) ]; then
        if [ -z "$starred" ]; then
            pending+=("the star ask (the first ask)")
        elif [ "$starred" = "maybe-later" ]; then
            pending+=("the star ask (the follow-up ask)")
        fi
    fi

    # The install signal. A person is asked once per version. It is normally
    # asked together with the welcome; it shows up here when that did not
    # lead to an answer.
    case "$(due_signal)" in
        "first")
            pending+=("the install signal (this person's first signal for this project; the full message)") ;;
        "upgrade")
            pending+=("the install signal (signal_kind upgrade; the short ask)") ;;
    esac

    [ "${#pending[@]}" -gt 0 ] || return 0

    local list="${pending[0]}"
    [ "${#pending[@]}" -gt 1 ] && list="$list, and ${pending[1]}"

    echo ""
    echo "Questions from the collabmem developers are pending for this user: $list."
    echo "After the next memory update in this session, ask them, one at a time (Post-update Verification, item 5)."
}

# --- Welcome ---
# Every person gets a short message from the collabmem developers in their
# first session with a version of collabmem in a project:
#
# - The welcome, for a person who never had one in this project: a
#   thank-you, how to get help, how to send feedback, where to get news. A
#   team member who received collabmem through a plain "git pull" never saw
#   the final message of an install; this is where they learn these things.
# - The upgrade message, for a person whose last message was for an older
#   version: that collabmem was upgraded, and where to read what is new.
#
# The personal file records the version of the last message, as the value
# "welcomed". The hook records it itself, so the AI does not have to run a
# command for it in the user's first session. It is recorded when the hook
# prints the message, not when the AI has said it: a message that is missed
# is better than one that comes twice.
#
# When the install signal is due, the message announces it, and the question
# is asked at the end of the same response, after the user's own request.
#
# Returns 0 when a message was printed, 1 when none was due.
print_welcome() {
    local version welcomed
    version=$(installed_version)
    [ -n "$version" ] || return 1

    welcomed=$(read_personal_value welcomed)
    [ "$welcomed" != "$version" ] || return 1

    # Record it first: when that fails, give no message at all.
    git config --file "$PERSONAL_FILE" \
        "project.$(pwd -P).welcomed" "$version" 2>/dev/null || return 1

    # At the first welcome, remember how large the memory is. The star ask
    # counts from here.
    if [ -z "$welcomed" ]; then
        local entries
        entries=$(grep -c '^| [0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9] ' \
            "$COLLAB_DIR/index.md" 2>/dev/null || true)
        git config --file "$PERSONAL_FILE" \
            "project.$(pwd -P).entries-at-welcome" "${entries:-0}" 2>/dev/null || true
    fi

    local signal
    signal=$(due_signal)

    echo ""
    echo "MESSAGE FROM THE COLLABMEM DEVELOPERS for this user, to give once."
    echo "In your FIRST response of this session, give the message below. It comes first in that"
    echo "response; only the load-check banner comes before it. Render it verbatim, then a"
    echo "horizontal line (---), then answer what the user asked."
    echo ""
    if [ -z "$welcomed" ]; then
        echo "    **From the collabmem developers:** welcome to collabmem, and thanks for using it! This project uses collabmem: a way for you and your AI assistant to collaborate over the long term and build up a shared memory of the work. More about it: https://github.com/visionscaper/collabmem"
        echo ""
        echo "    - Type \`helpmem\` when you want help with it."
        echo "    - Type \`feedbackmem\` to tell the developers about a problem or an idea."
        echo "    - For occasional news about collabmem: https://lucens.ai/subscribe/?source=collabmem-welcome"
    else
        echo "    **From the collabmem developers:** collabmem was upgraded to version $version in this project. Thanks for using it!"
        echo ""
        # The release notes have one section per version, with the heading
        # "## v1.8.7". GitHub makes the anchor "#v187" of that: lower case,
        # the dots dropped. The heading must stay bare for this to work.
        echo "    - What is new: https://github.com/visionscaper/collabmem/blob/main/release-notes.md#v$(printf '%s' "$version" | tr -d '.')"
        echo "    - Type \`helpmem\` for help, and \`feedbackmem\` to tell the developers about a problem or an idea."
        echo "    - For occasional news about collabmem: https://lucens.ai/subscribe/?source=collabmem-upgrade"
    fi

    [ -n "$signal" ] || return 0

    echo ""
    echo "    They also have one quick question for you. I will ask it at the end of this answer."
    echo ""
    echo "After your answer to the user, in the SAME response: a horizontal line (---), then the"
    echo "install signal question. It starts with:"
    echo ""
    echo "    **One quick question from the collabmem developers:**"
    echo ""
    echo "Follow $COLLAB_DIR/install-signal.md, \"When the session hook reports the signal as pending\"."
    if [ "$signal" = "first" ]; then
        echo "It is this person's first signal for this project: the full message."
    else
        echo "It is an upgrade signal (signal_kind upgrade): the short ask."
    fi
    echo "Do not wait for a memory update."

    return 0
}

# --- Messages from the developers, together ---
# At the start of a session: the welcome or the upgrade message when one is
# due, otherwise the questions that are still pending. With "pending-only":
# just the pending questions, for a session that continues.
# When the personal file cannot be used, nothing is asked. At the start of a
# session the problem is reported instead.
print_developer_messages() {
    # A load-check probe is a session of its own, started by an install, an
    # upgrade or the troubleshooting guide. No person reads it, so it gets no
    # message: otherwise the welcome would be recorded as given, and the real
    # user would never see it. The probe sets this variable.
    [ -z "${COLLABMEM_PROBE:-}" ] || return 0

    command -v git >/dev/null 2>&1 || return 0

    local state
    state=$(personal_file_state)
    if [ "$state" != "ok" ]; then
        [ "$1" = "pending-only" ] || print_personal_file_problem "$state"
        return 0
    fi

    if [ "$1" = "pending-only" ]; then
        print_pending_questions
    else
        print_welcome || print_pending_questions
    fi
}

# --- SessionStart ---
if [ "$HOOK_EVENT" = "SessionStart" ]; then
    SOURCE=$(json_field source)
    SOURCE="${SOURCE:-unknown}"

    case "$SOURCE" in
        "startup"|"clear")
            echo "=== Collaboration Memory System ==="
            echo "$CURRENT_DATETIME"
            echo ""
            check_health
            print_load_check
            echo ""
            echo "Only if the load-check passed, follow readmem — New Session:"
            echo "1. Check world/state.md for current work"
            echo "2. Scan recent index.md entries for context"
            echo "3. If unclear, search notes.md for recent notes"
            print_memory_triggers
            # The welcome or the upgrade message when one is due, with the
            # install signal question. Otherwise the pending questions. The
            # star ask never comes together with a welcome.
            print_developer_messages
            ;;

        "compact")
            echo "=== Collaboration Memory System — POST-COMPACTION ==="
            echo "$CURRENT_DATETIME"
            echo ""
            check_health
            echo "Your conversation history was just compacted. Do NOT continue from the summary alone."
            echo ""
            print_load_check
            echo ""
            echo "Only if the load-check passed, follow readmem — After Compaction:"
            echo "1. Search notes.md for the most recent session summary note"
            echo "2. Verify with the user what was being worked on before continuing"
            print_memory_triggers
            print_developer_messages pending-only
            ;;

        "resume")
            echo "=== Collaboration Memory System — Session Resumed ==="
            echo "$CURRENT_DATETIME"
            echo ""
            echo "Context should be intact. If uncertain about details, verify from notes and world model files."
            print_memory_triggers
            print_developer_messages pending-only
            ;;
    esac

    exit 0
fi

# --- UserPromptSubmit ---
if [ "$HOOK_EVENT" = "UserPromptSubmit" ]; then
    echo "$CURRENT_DATETIME"
    exit 0
fi

# For any other event, exit silently
exit 0
