# Sprint 2: Session View

**Duration:** ~2 weeks
**Status:** Not started
**Depends on:** Sprint 1

## Goal

Embed actual terminal views in the GUI so you can see and interact with Claude sessions without leaving nous. This is the heart of the 100x developer experience.

## What We'll Achieve

- xterm.js integrated and styled
- Terminal connected to tmux pane output
- Can type into terminal (input forwarding)
- Session focus view with full terminal
- Inline preview in dashboard
- Session metadata sidebar (files changed, duration, etc.)
- Pop-out session to separate window

## Key Questions to Answer

- How do we stream tmux pane output to xterm.js?
- What's the input forwarding mechanism?
- How do we handle terminal resize?
- Should we capture/parse Claude's output for richer display?

## Milestone

**"I can have a full conversation with Claude inside the nous GUI."**

## Spikes Needed

- [ ] xterm.js + React integration
- [ ] tmux capture-pane / pipe-pane for output
- [ ] Input forwarding via tmux send-keys
- [ ] Terminal resize handling

## Notes

_Fill in during sprint_

---

## Retrospective

_Fill in after sprint_

**What worked:**

**What didn't:**

**Decisions made:**
