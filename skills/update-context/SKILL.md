# Update Context Skill

Maintains CLAUDE.md as a lean, accurate, high-ROI context file for any project.

## Core Principles

1. **Concise > Comprehensive** - Target 120-150 lines maximum
2. **Delete > Add** - Prefer removing stale content over additions
3. **Durable > Transient** - Document only repeating patterns, not one-offs
4. **Point > Copy** - Reference external docs instead of duplicating content

## Update Modes

### Mode 1: Full Analysis (via /update-context command)

When triggered by the command, perform complete analysis:

1. **Read current CLAUDE.md** in full
2. **Analyze git history** to understand changes since last update:
   - Find when CLAUDE.md was last updated
   - Summarize meaningful changes (excluding docs, tests, CLAUDE.md itself)
3. **Classify changes** using standards.md:
   - **Must-add**: New critical patterns not yet documented
   - **Must-update**: Current content now wrong/misleading
   - **Should-remove**: Stale, redundant, or low-value content
4. **Output report** with these sections:
   - Summary of Changes Since Last Update (4-8 bullets)
   - Proposed Deletions (with reasons)
   - Proposed Modifications (before/after + reasoning)
   - Proposed Additions (only if high-value & durable)
   - Recommendation (minimal/medium/full refresh + line count)
5. **Wait for approval** before making changes; commit with descriptive message upon approval

### Mode 2: Targeted Update (ad-hoc requests)

When users request specific content updates:

1. Read current CLAUDE.md for structure and style
2. Research the topic in the codebase
3. Draft minimal addition fitting existing style
4. Validate against principles:
   - Is this durable across future sessions?
   - Already documented elsewhere (prefer links)?
   - Justifies its token cost?
   - Stays accurate without frequent updates?
5. Propose the edit showing exact location and before/after content
6. Apply after confirmation; commit with descriptive message

## Reference Materials

Detailed guidance available in `references/standards.md` covering content standards, style guidelines, and decision frameworks.
