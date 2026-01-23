# Nous GUI: Sprint Plan

High-level sprint breakdown for building the nous GUI. Each sprint is roughly 2 weeks.

## Overview

```
Sprint 0: Foundation          ──► Can list and switch sessions
    │
Sprint 1: Core Dashboard      ──► Live session activity visible
    │
Sprint 2: Session View        ──► Interact with sessions in GUI
    │
Sprint 3: Diff Integration    ──► Full git workflow in GUI
    │
Sprint 4: Multi-Server        ──► Manage sessions across machines
    │
Sprint 5: Polish & Ship       ──► Production-ready release
```

## Sprint Documents

| Sprint | Focus | Status |
|--------|-------|--------|
| [Sprint 0](./sprint-0-foundation.md) | Project setup, tmux bridge, basic UI | Not started |
| [Sprint 1](./sprint-1-dashboard.md) | Dashboard layout, file watching, activity stream | Not started |
| [Sprint 2](./sprint-2-session-view.md) | Embedded terminals, session interaction | Not started |
| [Sprint 3](./sprint-3-diff.md) | Git integration, diff viewer, staging | Not started |
| [Sprint 4](./sprint-4-multi-server.md) | Remote agents, SSH tunnels, cross-server view | Not started |
| [Sprint 5](./sprint-5-polish.md) | Animations, themes, packaging, release | Not started |

## How to Use

1. Before starting a sprint, read its document
2. Break down the goals into specific tasks
3. Update status as you progress
4. Document learnings and decisions
5. Move to next sprint when milestone is achieved

## Current Sprint

**None started yet**

---

## Quick Reference

**Tech Stack:**
- Tauri (Rust backend + web frontend)
- React 19 + Tailwind CSS
- xterm.js (embedded terminals)
- Monaco Editor (diffs)

**Key Principle:** Keep tmux as the session backend. GUI is a control layer, not a replacement.
