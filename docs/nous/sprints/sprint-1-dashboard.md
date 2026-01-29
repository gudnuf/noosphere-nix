# Sprint 1: Core Dashboard

**Duration:** ~2 weeks
**Status:** Not started
**Depends on:** Sprint 0

## Goal

Build the main dashboard view with real-time session activity. The dashboard becomes the home screen showing everything at a glance.

## What We'll Achieve

- Full dashboard layout (sessions panel + activity panel)
- Session groups with collapse/expand
- File system watcher running per session
- Activity stream showing file changes in real-time
- Session status indicators (active/idle/waiting)
- Basic styling with the deep-space theme

## Key Questions to Answer

- How do we attribute file changes to sessions?
- What's the right polling/watching strategy?
- How do we handle rapid file changes (debouncing)?
- What ignore patterns do we need?

## Milestone

**"I can see which files each Claude session is modifying as it happens."**

## Spikes Needed

- [ ] Rust `notify` crate for file watching
- [ ] Session-to-directory mapping strategy
- [ ] Real-time event streaming to frontend

## Notes

_Fill in during sprint_

---

## Retrospective

_Fill in after sprint_

**What worked:**

**What didn't:**

**Decisions made:**
