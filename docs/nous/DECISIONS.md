# Nous: Design Decisions

Record design decisions as you work through the iteration process. Each section corresponds to an iteration in `ITERATION.md`.

---

## Session Discovery

**Decision**: _TBD_

**Options Considered**:
- [ ] Explicit only (all sessions via `nous new`)
- [ ] Hybrid (detect + adopt existing)
- [ ] Full detection (scan all claude processes)

**Rationale**:

_Fill in after completing Iteration 2_

---

## File Attribution

**Decision**: _TBD_

**Options Considered**:
- [ ] Directory-based
- [ ] Process-based
- [ ] Git-based
- [ ] Hybrid

**Rationale**:

_Fill in after completing Iteration 3_

---

## Server Communication

**Decision**: _TBD_

**Options Considered**:
- [ ] SSH tunnel
- [ ] WebSocket
- [ ] Polling
- [ ] Hybrid

**Latency Requirements**:

**Reliability Requirements**:

**Rationale**:

_Fill in after completing Iteration 5_

---

## Deployment Integration

**Decision**: _TBD_

**Scope**:
- [ ] Show status only
- [ ] Preview changes
- [ ] Trigger deploys
- [ ] Full deployment management

**Current Workflow**:

_Document your current deployment process here_

**What Nous Will Handle**:

**What Stays Manual**:

**Rationale**:

_Fill in after completing Iteration 6_

---

## TUI Framework

**Decision**: _TBD_

**Options Considered**:
- [ ] Ink (React for CLI)
- [ ] Blessed / Neo-Blessed
- [ ] Bubble Tea (Go)
- [ ] Custom with Bun

**Spike Results**:

**Rationale**:

_Fill in after completing Iteration 7_

---

## State Persistence

**Decision**: _TBD_

| Data | Persistence | Location |
|------|-------------|----------|
| Active sessions | | |
| Session history | | |
| Groups | | |
| Servers | | |
| File changes | | |
| User preferences | | |

**Retention Policy**:

**Recovery Strategy**:

**Rationale**:

_Fill in after completing Iteration 8_

---

## Nix Integration

**Decision**: _TBD_

**Flake Location**:
- [ ] In noosphere-nix repo
- [ ] Separate nous repo
- [ ] Monorepo with agent

**Agent Distribution**:

**Config Location**:
- [ ] Nix only
- [ ] Runtime config file
- [ ] Hybrid

**Rationale**:

_Fill in after completing Iteration 12_

---

## Mobile Experience

**Decision**: _TBD_

**Primary Mobile Use Cases**:
- [ ] Quick status check
- [ ] Session switching
- [ ] View activity stream
- [ ] Full session management
- [ ] Deployment

**Mobile-Only Features**:

_Features specifically for mobile_

**Desktop-Only Features**:

_Features to defer from mobile_

**Responsive Breakpoints**:

| Mode | Min Cols | Min Rows |
|------|----------|----------|
| Mobile | | |
| Tablet | | |
| Desktop | | |

**Rationale**:

_Fill in after completing Iteration 13_

---

## Additional Decisions

_Add new sections as decisions come up during implementation_
