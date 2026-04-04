#!/bin/bash
#
# collab-memory-hook.sh — Lifecycle hook for the Collaboration Memory System
#
# Handles two Claude Code hook events:
#   - SessionStart: Context recovery, health check, and memory triggers
#   - UserPromptSubmit: Timestamp
#
# Install by adding to .claude/settings.json (see README for configuration).
# The script reads .collab-config from the project root for the collab directory path.
#

set -e

# Read hook input from stdin
INPUT=$(cat)

# Extract hook event name
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')

# Read .collab-config for collab directory path
CONFIG_FILE=".collab-config"
if [ -f "$CONFIG_FILE" ]; then
    COLLAB_DIR=$(grep '^collab_dir=' "$CONFIG_FILE" | cut -d'=' -f2)
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

# --- Memory triggers ---
# Republished at session start for primacy position in context window.
# Same trigger list as methodology Section 10.
print_memory_triggers() {
    echo ""
    echo "IMPORTANT: After each user message or your response, consider whether an episodic memory note and/or world model update should be made, for instance when:"
    echo "- A logical unit of work concluded — e.g. a discussion produced decisions, a design, a plan, or conclusions; a piece of implementation work was completed (feature, fix, refactor, investigation)"
    echo "- The user shared context, preferences, or corrected your understanding — e.g. personal/project/business context, working preferences, factual corrections, new procedures or domain knowledge"
    echo "- A commit is about to happen for non-trivial work"
    echo "- The session is being compacted soon or the session is ending — review and update world/state.md when relevant"
    echo "Propose updates to the user — also see methodology Sections 3, 4, and 10."
    echo "Keep index.md and world/index.md in sync with any changes."
    echo ""
    echo "When searching for information, check in-context indexes before searching files."
}

# --- SessionStart ---
if [ "$HOOK_EVENT" = "SessionStart" ]; then
    SOURCE=$(echo "$INPUT" | jq -r '.source // "unknown"')

    case "$SOURCE" in
        "startup"|"clear")
            echo "=== Collaboration Memory System ==="
            echo "$CURRENT_DATETIME"
            echo ""
            check_health
            echo "Tier 1 files loaded via imports. Follow methodology Section 8 (New Session):"
            echo "1. Check world/state.md for current work"
            echo "2. Scan recent index.md entries for context"
            echo "3. If unclear, search notes.md for recent notes"
            print_memory_triggers
            ;;

        "compact")
            echo "=== Collaboration Memory System — POST-COMPACTION ==="
            echo "$CURRENT_DATETIME"
            echo ""
            check_health
            echo "Your conversation history was just compacted. Do NOT continue from the summary alone."
            echo ""
            echo "Tier 1 files (indexes, world model) have been re-read from disk — they reflect the latest state."
            echo ""
            echo "Follow methodology Section 8 (After Compaction):"
            echo "1. Search notes.md for the most recent session summary note"
            echo "2. Verify with the user what was being worked on before continuing"
            print_memory_triggers
            ;;

        "resume")
            echo "=== Collaboration Memory System — Session Resumed ==="
            echo "$CURRENT_DATETIME"
            echo ""
            echo "Context should be intact. If uncertain about details, verify from notes and world model files."
            print_memory_triggers
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
