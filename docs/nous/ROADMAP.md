# Nous: Implementation Roadmap

Phased implementation plan. Finalize after completing all iterations.

---

## Phase 1: Foundation

**Goal**: Basic local session tracking and navigation

### Deliverables

- [ ] Bun project structure
- [ ] Tmux session discovery
- [ ] In-memory session state
- [ ] Basic TUI rendering (session list)
- [ ] j/k navigation
- [ ] Enter to focus (jump to pane)

### Technical Tasks

```
[ ] Initialize Bun project
[ ] Set up TypeScript config
[ ] Implement tmux pane discovery
[ ] Create Session data model
[ ] Build basic TUI layout
[ ] Implement keyboard handling
[ ] Add tmux pane focus command
```

### Success Criteria

- [ ] `nous` launches and shows running claude sessions
- [ ] Can navigate with j/k
- [ ] Enter switches to that tmux pane

---

## Phase 2: File Tracking

**Goal**: Real-time file change monitoring per session

### Deliverables

- [ ] File watcher per session directory
- [ ] Activity stream in TUI
- [ ] Change attribution to sessions
- [ ] OSC 8 clickable file paths
- [ ] Open file in editor on click

### Technical Tasks

```
[ ] Implement file watcher wrapper
[ ] Add debouncing
[ ] Configure ignore patterns
[ ] Create FileChange data model
[ ] Build activity stream component
[ ] Implement OSC 8 link generation
[ ] Add editor open command
```

### Success Criteria

- [ ] File changes appear in real-time
- [ ] Changes attributed to correct session
- [ ] Clicking file opens in neovim

---

## Phase 3: Groups and Views

**Goal**: Organize sessions into groups, filter views

### Deliverables

- [ ] Group CRUD operations
- [ ] Auto-assign rules
- [ ] View filters (all, group, active)
- [ ] Persistent group config
- [ ] Group management screen

### Technical Tasks

```
[ ] Create Group data model
[ ] Implement group persistence (JSON/SQLite)
[ ] Build group management TUI
[ ] Add auto-assign logic
[ ] Implement view filtering
[ ] Add group color coding
```

### Success Criteria

- [ ] Can create/edit/delete groups
- [ ] Sessions auto-assign based on directory
- [ ] Can filter view to show only one group

---

## Phase 4: Diff Integration

**Goal**: View file diffs within nous

### Deliverables

- [ ] Diff view screen
- [ ] Per-file diff display
- [ ] Aggregated session diff
- [ ] Delta-style rendering
- [ ] Git staging integration

### Technical Tasks

```
[ ] Integrate with git diff
[ ] Build diff viewer component
[ ] Implement syntax highlighting
[ ] Add file selection in diff view
[ ] Implement staging commands
[ ] Add hunk navigation
```

### Success Criteria

- [ ] Press `d` to see diff for session
- [ ] Can navigate between files
- [ ] Can stage files from within nous

---

## Phase 5: Multi-Server

**Goal**: Track sessions across remote servers

### Deliverables

- [ ] Nous agent binary
- [ ] SSH tunnel communication
- [ ] Server connection management
- [ ] Cross-server activity stream
- [ ] Servers overview screen

### Technical Tasks

```
[ ] Create agent entry point
[ ] Implement agent protocol
[ ] Build SSH tunnel manager
[ ] Add server config persistence
[ ] Create server connection TUI
[ ] Aggregate remote session data
[ ] Handle disconnection gracefully
```

### Success Criteria

- [ ] Agent runs on remote server
- [ ] Coordinator connects via SSH
- [ ] Remote sessions appear in TUI
- [ ] File changes stream from remote

---

## Phase 6: Deployment

**Goal**: Nix deployment integration

### Deliverables

- [ ] Config sync status view
- [ ] Deployment preview
- [ ] Deploy trigger
- [ ] Deployment log view
- [ ] Closure diff display

### Technical Tasks

```
[ ] Detect deployed config version
[ ] Compare with local config
[ ] Build sync status TUI
[ ] Implement deploy preview
[ ] Add deploy command execution
[ ] Stream deployment output
[ ] Parse closure diff
```

### Success Criteria

- [ ] See which servers are out of sync
- [ ] Preview what will change
- [ ] Deploy from within nous
- [ ] Watch deployment progress

---

## Phase 7: Polish

**Goal**: Production-ready release

### Deliverables

- [ ] Nix flake packaging
- [ ] Home Manager module
- [ ] Full documentation
- [ ] Deep blue theme finalized
- [ ] All keybindings configurable
- [ ] Error handling complete

### Technical Tasks

```
[ ] Create flake.nix for nous
[ ] Build Home Manager module
[ ] Write user documentation
[ ] Implement theme system
[ ] Add keybinding config
[ ] Audit error handling
[ ] Add logging/debug mode
[ ] Performance optimization
```

### Success Criteria

- [ ] `nix run github:you/nous` works
- [ ] Configurable via Nix
- [ ] Handles edge cases gracefully

---

## Phase 8: Mobile

**Goal**: Responsive mobile-optimized experience

### Deliverables

- [ ] Mobile layout detection
- [ ] Compressed single-column views
- [ ] Touch-friendly navigation
- [ ] Swipe gesture support (if feasible)
- [ ] Bottom action bar
- [ ] Offline tolerance

### Technical Tasks

```
[ ] Implement terminal size detection
[ ] Create mobile layout variants
[ ] Build compressed dashboard
[ ] Build mobile session detail
[ ] Add bottom action bar component
[ ] Test on Termius (iOS/Android)
[ ] Handle connection drops gracefully
[ ] Add --mobile flag override
```

### Success Criteria

- [ ] Usable on phone in portrait mode
- [ ] Core actions work with on-screen keyboard
- [ ] Graceful degradation on disconnect

---

## Stretch Goals

Features for future versions:

| Feature | Phase | Notes |
|---------|-------|-------|
| Session output viewer | 9 | View Claude conversation |
| Search | 9 | Fuzzy find across everything |
| Notifications | 9 | Desktop alerts |
| Session templates | 10 | Predefined configurations |
| Plugin system | 11 | Extensibility |
| Team features | 12 | Shared context |
| Native mobile app | 13 | iOS/Android with push notifications |
| Voice input | 14 | Dictate prompts on mobile |
| Watch complication | 15 | Session status on Apple Watch |

---

## Dependencies

External dependencies to evaluate:

| Dependency | Purpose | Version |
|------------|---------|---------|
| Bun | Runtime | latest |
| _TUI library_ | UI rendering | |
| _SSH library_ | Tunnel management | |
| | | |

---

## Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Phase 1 complete (Foundation) | | |
| Phase 2 complete (File Tracking) | | |
| Phase 3 complete (Groups) | | |
| Phase 4 complete (Diffs) | | |
| Phase 5 complete (Multi-Server) | | |
| Phase 6 complete (Deployment) | | |
| Phase 7 complete (Polish) | | |
| Phase 8 complete (Mobile) | | |
| v1.0 release | | |
