# Sprint 0: Foundation

**Duration:** ~2 weeks
**Status:** Not started

## Goal

Set up the project structure and prove the core technical concepts work together. By the end, we have a working app that can list tmux sessions and switch between them.

## What We'll Achieve

- Tauri project initialized with React frontend
- Rust backend can communicate with tmux
- Basic window with session list
- Keyboard navigation works (j/k, Enter)
- Can focus a session (switches tmux pane)

## Key Questions to Answer

- Does Tauri + React feel right for this project?
- Can we reliably get session info from tmux via Rust?
- What's the IPC pattern between frontend and backend?
- How do we handle the dev workflow (hot reload, etc.)?

## Milestone

**"I can see my Claude sessions in a GUI window and switch between them with the keyboard."**

## Spikes Needed

- [ ] Tauri hello world with React
- [ ] Rust tmux-interface crate exploration
- [ ] IPC command pattern (Rust ↔ JS)

## Notes

_Fill in during sprint_

---

## Retrospective

_Fill in after sprint_

**What worked:**

**What didn't:**

**Decisions made:**
