# Nous: Iteration Process

This document provides actionable steps for iterating on the nous design until we have it how we want.

## How to Use This Document

Work through each section in order. Each section contains:
- **Goal**: What we're trying to decide or clarify
- **Questions**: Specific questions to answer
- **Exercise**: An activity to help make decisions
- **Output**: What to document when done

Check off items as you complete them. After each section, update `PLAN.md` with decisions made.

---

## Iteration 1: Core Workflow Validation

**Goal**: Confirm the basic interaction model matches how you actually work.

### Questions
- [ ] How many Claude sessions do you typically run simultaneously?
- [ ] How often do you switch between them?
- [ ] What triggers a switch? (task complete, blocked, context switch)
- [ ] Do you ever need to see two sessions' output at once?
- [ ] How do you currently track "what was that Claude working on"?

### Exercise
For the next few work sessions, keep a log:
```
Time | Action | Why
-----|--------|----
10:30 | switched to api-session | needed to check auth implementation
10:45 | switched to ui-session | api waiting for my input
11:00 | started new session | new task came up
```

### Output
Document your switching patterns in `WORKFLOW.md`. Note any pain points.

---

## Iteration 2: Session Discovery Design

**Goal**: Decide how nous finds and tracks Claude sessions.

### Questions
- [ ] Must sessions be started via `nous new` or should nous detect existing claude processes?
- [ ] If detection: how do we name auto-discovered sessions?
- [ ] Should nous take over tmux session management or work alongside your existing setup?
- [ ] What metadata do we need to capture at session start?

### Options to Consider

**Option A: Explicit Only**
- All sessions started via `nous new`
- Full control over naming, grouping, directory
- Won't see sessions started with raw `claude` command

**Option B: Hybrid**
- `nous new` for intentional sessions
- Auto-detect existing claude processes
- Prompt to "adopt" unnamed sessions

**Option C: Full Detection**
- Scan for all claude processes
- Infer directory from tmux pane cwd
- Auto-name based on directory

### Exercise
Try starting a few sessions different ways and note what information would be available:
```bash
# In tmux pane 1
cd ~/projects/api && claude

# In tmux pane 2
nous new --name "ui-work" --dir ~/projects/app

# What can nous know about each?
```

### Output
Add "Session Discovery" section to `DECISIONS.md` with chosen approach.

---

## Iteration 3: File Change Attribution

**Goal**: Decide how to attribute file changes to sessions.

### Questions
- [ ] If two sessions have overlapping directories, how do we attribute changes?
- [ ] Should we track at git level (what changed) or fs level (real-time)?
- [ ] How important is it to see changes *as they happen* vs after the fact?
- [ ] Do we need to track file reads or just writes?

### Options to Consider

**Option A: Directory-Based**
- Each session "owns" its working directory
- Changes in that directory attributed to that session
- Conflict when directories overlap

**Option B: Process-Based**
- Hook into file writes at the process level
- Know exactly which claude wrote which file
- More complex, possibly platform-specific

**Option C: Git-Based**
- Poll `git status` periodically
- Know what changed but not which session
- Simple, reliable, but less real-time

**Option D: Hybrid**
- Directory-based for real-time stream
- Git-based for accurate diff/staging
- Reconcile conflicts manually

### Exercise
Create a scenario with overlapping work:
1. Start two sessions in the same repo
2. Have each modify different files
3. Note: could nous tell them apart?

### Output
Add "File Attribution" section to `DECISIONS.md`.

---

## Iteration 4: Navigation UX

**Goal**: Refine the keyboard navigation model.

### Questions
- [ ] Is vim-style j/k sufficient or do you want arrow keys too?
- [ ] How deep should the hierarchy go? (servers → groups → sessions → files)
- [ ] What's the most common "I need to get to X" scenario?
- [ ] Should Enter always mean "go to tmux pane" or context-dependent?

### Exercise
Paper prototype: draw the main screen and trace through these scenarios with your finger:
1. "Switch to the session working on auth"
2. "See what files changed in the frontend group"
3. "Open the file that was just modified"
4. "Start a new session on hetzner"

Note where you get stuck or where it feels like too many keystrokes.

### Output
Update keybindings table in `PLAN.md` if changes needed.

---

## Iteration 5: Server Communication

**Goal**: Design the multi-server architecture.

### Questions
- [ ] How reliable is your connection to hetzner/other servers?
- [ ] Is latency a concern for real-time file updates?
- [ ] Do you need to work offline and sync later?
- [ ] How do you currently deploy to these servers?

### Options to Consider

**Option A: SSH Tunnel**
- Nous agent listens on localhost
- SSH forwards port to coordinator
- Reuses existing SSH auth
- Might be flaky over bad connections

**Option B: WebSocket**
- Agent exposes WebSocket endpoint
- Direct connection from coordinator
- Need separate auth mechanism
- Better for real-time

**Option C: Polling**
- Coordinator SSH's in periodically
- Grabs state dump from agent
- Simplest, most reliable
- Not real-time

**Option D: Hybrid**
- WebSocket when available
- Fall back to polling when connection unstable
- Buffer changes during disconnection

### Exercise
Test your connection to each server:
```bash
# Latency
ping -c 10 77.42.27.244

# SSH stability over 10 minutes
ssh claude@77.42.27.244 "while true; do date; sleep 10; done"
```

### Output
Add "Server Communication" section to `DECISIONS.md`.

---

## Iteration 6: Deployment Integration

**Goal**: Define how nous integrates with your nix deployment workflow.

### Questions
- [ ] Should nous trigger deploys or just show what needs deploying?
- [ ] How do you currently know if a server's config is out of date?
- [ ] Do you want to preview nix closure diffs before deploying?
- [ ] Should deploy happen per-server or batch?

### Current Workflow
Document your current deployment process:
```bash
# What commands do you run?
# What do you check before deploying?
# What do you check after?
```

### Exercise
Deploy to hetzner and note every piece of information you look at:
- [ ] Git status before
- [ ] What's different from deployed version
- [ ] Build output
- [ ] Activation output
- [ ] Post-deploy verification

### Output
Add "Deployment" section to `DECISIONS.md` specifying:
- What nous shows
- What nous can trigger
- What stays manual

---

## Iteration 7: TUI Framework Selection

**Goal**: Choose the TUI implementation approach.

### Options

**Option A: Ink (React for CLI)**
- Familiar React patterns
- Good component model
- Npm ecosystem
- Might be heavy for simple UI

**Option B: Blessed / Neo-Blessed**
- Battle-tested
- Rich widget set
- Node.js based
- Old-ish, some quirks

**Option C: Bubble Tea (Go)**
- Excellent design
- Would require Go instead of Bun
- Very active community

**Option D: Custom with Bun**
- Direct ANSI escape codes
- Full control
- More work, but exactly what we want
- Could use a light library like `ansi-escapes`

### Exercise
Build a minimal prototype with top two choices:
```typescript
// 10-minute spike: can you render a list and handle j/k?
```

### Output
Add "TUI Framework" section to `DECISIONS.md` with choice and rationale.

---

## Iteration 8: State Persistence

**Goal**: Define what gets persisted and where.

### Questions
- [ ] Should session history survive system restart?
- [ ] How long to retain file change history?
- [ ] Do groups and servers need to sync across machines?
- [ ] What's the recovery story if state gets corrupted?

### Data Categories

| Data | Persistence | Location |
|------|-------------|----------|
| Active sessions | Memory | - |
| Session history | SQLite | `~/.local/share/nous/` |
| Groups | Config file | `~/.config/nous/` |
| Servers | Nix config | `home/modules/nous.nix` |
| File changes | SQLite | `~/.local/share/nous/` |
| User preferences | Config file | `~/.config/nous/` |

### Exercise
Think about these scenarios:
1. You restart your machine - what should nous remember?
2. You re-image your machine and restore from nix config - what's preserved?
3. You want to see what you worked on last week - is that available?

### Output
Add "State Persistence" section to `DECISIONS.md`.

---

## Iteration 9: MVP Scope

**Goal**: Define the minimal viable version to start using.

### Candidate MVP Features

**Must Have**
- [ ] Session list with status
- [ ] j/k navigation
- [ ] Enter to focus (jump to tmux pane)
- [ ] File change stream
- [ ] Clickable files (open in editor)

**Should Have**
- [ ] Groups
- [ ] Basic diff view
- [ ] New session creation

**Nice to Have**
- [ ] Multi-server
- [ ] Deployment integration
- [ ] Search

### Exercise
Imagine you have only the "Must Have" features. Use nous for a day:
- What's painful without groups?
- What's painful without diff?
- What's painful without multi-server?

Rank the "Should Have" and "Nice to Have" by pain level.

### Output
Create `MVP.md` with:
- Exact feature list for v0.1
- What's explicitly deferred
- Success criteria ("I'll know it's working when...")

---

## Iteration 10: Technical Spike

**Goal**: Validate key technical assumptions with code.

### Spikes to Run

**Spike 1: Tmux Discovery**
```bash
# Can we reliably find claude processes and their panes?
tmux list-panes -a -F '#{pane_id}:#{pane_pid}:#{pane_current_command}:#{pane_current_path}'
```
- Does this work on Linux and macOS?
- Can we get child process info?

**Spike 2: File Watching with Bun**
```typescript
// Does Bun's file watcher perform well enough?
import { watch } from "fs";
watch("./", { recursive: true }, (event, filename) => {
  console.log(event, filename);
});
```
- Debounce behavior?
- Ignore patterns?

**Spike 3: OSC 8 Hyperlinks**
```typescript
// Do clickable links work in your terminal?
const link = (url: string, text: string) =>
  `\x1b]8;;${url}\x1b\\${text}\x1b]8;;\x1b\\`;
console.log(link("file:///Users/claude/test.ts", "test.ts"));
```
- Works in iTerm2? Kitty? Alacritty?

**Spike 4: SSH Tunnel**
```bash
# Can we maintain a stable tunnel?
ssh -L 9999:localhost:9999 claude@77.42.27.244 "nc -l 9999"
```
- Reconnection behavior?
- Latency?

### Output
Document spike results in `SPIKES.md` with:
- What worked
- What didn't
- Adjusted assumptions

---

## Iteration 11: Project Structure

**Goal**: Define the codebase organization.

### Proposed Structure
```
nous/
├── src/
│   ├── cli/              # CLI entry point, argument parsing
│   ├── tui/              # TUI components and screens
│   ├── core/             # Business logic
│   │   ├── session.ts    # Session management
│   │   ├── watcher.ts    # File watching
│   │   ├── group.ts      # Group management
│   │   └── server.ts     # Server communication
│   ├── agent/            # Remote agent code
│   ├── db/               # SQLite schema and queries
│   └── config/           # Configuration loading
├── package.json
├── tsconfig.json
├── build.ts              # Bun build script
└── README.md
```

### Questions
- [ ] Monorepo (coordinator + agent) or separate packages?
- [ ] How do we build/distribute the agent binary?
- [ ] Where does the Nix packaging live?

### Output
Create initial project structure (empty files with TODO comments).

---

## Iteration 12: Nix Integration

**Goal**: Design how nous integrates with your nix-config.

### Questions
- [ ] Where does the nous flake live? (this repo? separate?)
- [ ] How is the agent deployed to servers?
- [ ] How do we handle nous config in nix vs runtime config?

### Proposed Integration
```nix
# flake.nix
inputs.nous.url = "github:you/nous";

# home/modules/nous.nix
{ inputs, ... }:
{
  imports = [ inputs.nous.homeManagerModules.default ];

  programs.nous = {
    enable = true;
    # ... config
  };
}
```

### Output
Add "Nix Integration" section to `DECISIONS.md`.

---

## Iteration 13: Mobile Experience

**Goal**: Validate mobile UX design and constraints.

### Questions
- [ ] How often do you use Claude Code from mobile?
- [ ] What tasks do you typically do on mobile vs desktop?
- [ ] Is Termius your only mobile SSH client?
- [ ] What's the typical terminal size on your phone?
- [ ] Do you use landscape or portrait orientation?

### Exercise
Use nous (or imagine using it) on mobile for a work session:

1. SSH to your machine via Termius
2. Note the terminal dimensions: `echo $COLUMNS x $LINES`
3. Try navigating with the on-screen keyboard
4. Note which actions feel awkward

### Mobile Testing Checklist

```bash
# On phone, check terminal size
echo "Columns: $COLUMNS, Lines: $LINES"

# Test keyboard experience
# - How easy is j/k navigation?
# - Can you hit Enter reliably?
# - Is Esc accessible?
```

### Output
Add "Mobile Experience" section to `DECISIONS.md`:
- Primary mobile use cases
- Must-have mobile features
- Features to defer for desktop-only
- Responsive breakpoint decisions

---

## After All Iterations

Once you've worked through all iterations:

1. **Consolidate decisions** into final `PLAN.md`
2. **Create `ROADMAP.md`** with prioritized phases
3. **Set up the repository** based on project structure
4. **Build MVP** following the defined scope
5. **Iterate** based on actual usage

---

## Quick Reference: Files to Create

| File | Purpose |
|------|---------|
| `PLAN.md` | Overall design document (exists) |
| `SCREENS.md` | TUI mockups |
| `DECISIONS.md` | Record of design decisions |
| `WORKFLOW.md` | Your observed work patterns |
| `MVP.md` | Minimal viable product scope |
| `SPIKES.md` | Technical spike results |
| `ROADMAP.md` | Phased implementation plan |
