# Release Notes

## v1.1

**Changes since v1.0 (commit `7f3037c`):**

- **methodology.md**: New `#### Writing World Model Knowledge` subsection — Tier 1 quality principle, doc reference convention, Tier 2 content structuring. Configurable character cap via `.collab-config` (replaces hardcoded ~5,000). Context pressure awareness in Section 7 — AI should proactively ask user about remaining context and propose a note before compaction occurs.
- **install.md**: Default import placement changed to end of instruction file. World model seeding order. Doc consolidation step. Transition notice for migration scenarios.
- **.collab-config**: New `tier_1_max_chars=5000` setting.
- **README.md**: Context compaction warning in Usage Tips.

**Upgrade from v1.0:**

1. Compare changes: `git diff 7f3037c..HEAD` in the ai-collab-memory repo
2. Copy updated files to your installation:
   - `collab/methodology.md` → your collab directory
   - `install.md` is reference only (not installed) — no action needed unless re-installing
3. Add `tier_1_max_chars=5000` to your `.collab-config`
