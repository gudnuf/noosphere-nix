# Sprint 4: Multi-Server

**Duration:** ~2 weeks
**Status:** Not started
**Depends on:** Sprint 3

## Goal

Extend nous to manage Claude sessions across multiple machines. One dashboard to rule them all.

## What We'll Achieve

- nous-agent binary (Rust, runs on remote servers)
- SSH tunnel management for secure communication
- Server connection UI (add, remove, status)
- Remote sessions appear in dashboard
- Cross-server activity stream
- Graceful handling of disconnects
- Reconnection logic

## Key Questions to Answer

- SSH tunnel vs WebSocket vs other transport?
- How do we deploy the agent to servers?
- What's the protocol between GUI and agent?
- How do we handle latency for file watching?
- What happens when connection drops mid-session?

## Milestone

**"I can see and switch between Claude sessions on my laptop, hetzner, and nixos-vm from one window."**

## Spikes Needed

- [ ] Agent binary structure
- [ ] SSH tunnel in Rust (russh crate)
- [ ] Agent ↔ GUI protocol design
- [ ] Connection state management

## Notes

_Fill in during sprint_

---

## Retrospective

_Fill in after sprint_

**What worked:**

**What didn't:**

**Decisions made:**
