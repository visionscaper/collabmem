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

# Reads one value of this project from the personal file; empty when absent.
read_personal_value() {
    local personal_file="$HOME/.config/collabmem/personal.ini"
    [ -f "$personal_file" ] || return 0

    # The same path the procedures use when they write a value.
    git config --file "$personal_file" \
        --get "project.$(pwd -P).$1" 2>/dev/null || true
}

print_pending_questions() {
    command -v git >/dev/null 2>&1 || return 0

    local pending=()

    # An index entry is a table row that starts with a date.
    local entries
    entries=$(grep -c '^| [0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9] ' \
        "$COLLAB_DIR/index.md" 2>/dev/null || true)
    entries="${entries:-0}"

    # The star ask. It waits until the memory has at least 5 entries: the
    # user has seen the system work by then.
    local starred
    starred=$(read_personal_value project-starred)
    if [ "$entries" -ge 5 ]; then
        if [ -z "$starred" ]; then
            pending+=("the star ask (the first ask)")
        elif [ "$starred" = "maybe-later" ]; then
            pending+=("the star ask (the follow-up ask)")
        fi
    fi

    # The install signal. It needs the install ID of the project; without
    # one there is nothing to send. A person is asked once per version.
    local version signal signal_version
    version=$(sed 's/^v//' "$COLLAB_DIR/.collab-memory-system" 2>/dev/null \
        | tr -d '[:space:]' || true)
    if [ -f "$COLLAB_DIR/.install-id" ] && [ -n "$version" ]; then
        signal=$(read_personal_value signal)
        signal_version=$(read_personal_value signal-version)
        if [ -z "$signal" ]; then
            pending+=("the install signal (this person's first signal for this project; the full message)")
        elif [ "$signal" != "declined" ] && [ "$signal_version" != "$version" ]; then
            pending+=("the install signal (signal_kind upgrade; the short ask)")
        fi
    fi

    [ "${#pending[@]}" -gt 0 ] || return 0

    local list="${pending[0]}"
    [ "${#pending[@]}" -gt 1 ] && list="$list, and ${pending[1]}"

    echo ""
    echo "Questions from the collabmem developers are pending for this user: $list."
    echo "After the next memory update in this session, ask them, one at a time (Post-update Verification, item 5)."
}

# --- Welcome ---
# Every person gets one welcome from the collabmem developers, in their first
# session in a project: a thank-you, how to get help, how to send feedback,
# and where to get news. A team member who received collabmem through a plain
# "git pull" never saw the final message of an install; this is where they
# learn these things.
#
# The hook records the welcome itself, in the user's personal file, so the AI
# does not have to run a command for it in the user's first session. It is
# recorded when the hook prints it, not when the AI has said it: a welcome
# that is missed is better than one that comes twice.
#
# Returns 0 when the welcome was printed, 1 when it was not due.
print_welcome() {
    command -v git >/dev/null 2>&1 || return 1
    [ -z "$(read_personal_value welcomed)" ] || return 1

    # Record it first. When the personal file cannot be written, give no
    # welcome at all: otherwise it would come back in every session.
    local personal_file="$HOME/.config/collabmem/personal.ini"
    mkdir -p "$(dirname "$personal_file")" 2>/dev/null || return 1
    git config --file "$personal_file" \
        "project.$(pwd -P).welcomed" yes 2>/dev/null || return 1

    # Is the install signal due for this person? Same test as in
    # print_pending_questions, for a person with no signal answer yet.
    local version signal_due=""
    version=$(sed 's/^v//' "$COLLAB_DIR/.collab-memory-system" 2>/dev/null \
        | tr -d '[:space:]' || true)
    if [ -f "$COLLAB_DIR/.install-id" ] && [ -n "$version" ] \
        && [ -z "$(read_personal_value signal)" ]; then
        signal_due="yes"
    fi

    echo ""
    echo "WELCOME FROM THE COLLABMEM DEVELOPERS: this user has not had it yet in this project."
    echo "In your FIRST response of this session, give the welcome below. It comes first in that"
    echo "response; only the load-check banner comes before it. Render it verbatim, then a"
    echo "horizontal line (---), then answer what the user asked."
    echo ""
    echo "    **From the collabmem developers:** thanks for using collabmem!"
    echo ""
    echo "    - Type \`helpmem\` when you want help with it."
    echo "    - Type \`feedbackmem\` to tell the developers about a problem or an idea."
    echo "    - For occasional news about collabmem: https://lucens.ai/subscribe/?source=collabmem-welcome"
    if [ -n "$signal_due" ]; then
        echo ""
        echo "    They also have one quick question for you. I will ask it at the end of this answer."
        echo ""
        echo "After your answer to the user, in the SAME response: a horizontal line (---), then the"
        echo "install signal question. It starts with:"
        echo ""
        echo "    **One quick question from the collabmem developers:**"
        echo ""
        echo "Follow $COLLAB_DIR/install-signal.md, \"When the session hook reports the signal as pending\":"
        echo "this person's first signal for this project, the full message. Do not wait for a memory update."
    fi

    return 0
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
            # A person's first session gets the welcome, with the install
            # signal question when it is due. The star ask is left for a
            # later session.
            print_welcome || print_pending_questions
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
            print_pending_questions
            ;;

        "resume")
            echo "=== Collaboration Memory System — Session Resumed ==="
            echo "$CURRENT_DATETIME"
            echo ""
            echo "Context should be intact. If uncertain about details, verify from notes and world model files."
            print_memory_triggers
            print_pending_questions
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
