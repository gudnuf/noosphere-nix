# Sprint 3: Diff Integration

**Duration:** ~2 weeks
**Status:** Not started
**Depends on:** Sprint 2

## Goal

Full git integration so you can see what changed, stage files, and commit without leaving nous. Make reviewing Claude's changes effortless.

## What We'll Achieve

- Git diff via Rust git2 library
- Monaco editor for diff viewing
- Side-by-side and unified diff modes
- Syntax highlighting in diffs
- Stage/unstage individual files
- Stage/unstage individual hunks
- Commit dialog with message
- Open file in external editor

## Key Questions to Answer

- Monaco vs custom diff component?
- How deep does hunk-level staging go?
- Do we need branch management?
- How do we handle repos with submodules?

## Milestone

**"I can review all of Claude's changes and commit them without touching the terminal."**

## Spikes Needed

- [ ] Rust git2 crate for diff generation
- [ ] Monaco diff editor integration
- [ ] Staging workflow UX

## Notes

_Fill in during sprint_

---

## Retrospective

_Fill in after sprint_

**What worked:**

**What didn't:**

**Decisions made:**
