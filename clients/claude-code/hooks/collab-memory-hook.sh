#!/bin/bash
#
# collab-memory-hook.sh — Lifecycle hook for the Collaboration Memory System
# collabmem hook, checked and updated up to: v1.8.6
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
    echo "d) If the collabmem methodology marker (COLLABMEM-MARKER- joined with"
    echo "   METHODOLOGY) or the collabmem hook output appears more than once, then"
    echo "   more than one collabmem install is active over the same memory. Tell"
    echo "   the user before doing anything else and consult the \"duplicate"
    echo "   installs\" note in the troubleshooting guide (same locations as above);"
    echo "   do not proceed as if this were a single install."
}

# --- Memory triggers ---
# Republished at session start for primacy position in context window.
# Sentinel token names create attention matches to methodology headings.
print_memory_triggers() {
    echo ""
    echo "IMPORTANT: The user may include readmem, updatemem, maintainmem, upgrademem, or helpmem in their messages — when present, you MUST perform the corresponding operation."
    echo "The methodology also defines word cues and conceptual triggers for automatic memory operations."
    echo "When searching for information, check your context window for World Model Index or Episodic Memory Index entries before searching files."
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
            print_load_check
            echo ""
            echo "Only if the load-check passed, follow readmem — New Session:"
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
            print_load_check
            echo ""
            echo "Only if the load-check passed, follow readmem — After Compaction:"
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
