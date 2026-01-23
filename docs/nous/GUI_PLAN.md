# Nous GUI: Full Graphical Interface Plan

A comprehensive plan to evolve nous from a TUI into a full graphical interface while preserving the keyboard-driven, developer-first experience.

## Executive Summary

**Recommendation**: Build a **Tauri-based GUI** that wraps and enhances the existing tmux-based session management rather than replacing it. This gives us the best of both worlds: tmux's battle-tested terminal multiplexing with a beautiful graphical overlay for orchestration, visualization, and enhanced UX.

---

## Part 1: Core Architecture Decision

### Keep tmux vs Roll Our Own?

**Decision: Keep tmux**

| Factor | tmux | Roll Our Own |
|--------|------|--------------|
| Terminal emulation | Battle-tested, decades of fixes | Would need to implement/embed |
| Session persistence | Built-in, survives crashes | Must implement |
| Performance | Native C, minimal overhead | Additional layer |
| Remote sessions | SSH + tmux just works | Complex to replicate |
| Development time | Focus on GUI | Months on basics |
| Edge cases | Handled | Discover painfully |

**Architecture:**
```
┌────────────────────────────────────────────────────────────────┐
│                      Nous GUI (Tauri)                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    React Frontend                         │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │  │
│  │  │Dashboard│  │Sessions │  │  Diffs  │  │  Settings   │  │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Rust Backend                           │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │  │
│  │  │  tmux   │  │   Git   │  │   FS    │  │    SSH      │  │  │
│  │  │ bridge  │  │ bridge  │  │ watcher │  │  tunnels    │  │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                     tmux (existing)                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │
│  │ Session 1│  │ Session 2│  │ Session 3│  │  Session N   │   │
│  │  claude  │  │  claude  │  │  claude  │  │   claude     │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┘   │
└────────────────────────────────────────────────────────────────┘
```

---

## Part 2: Technology Stack

### Why Tauri?

| Framework | Bundle Size | Memory | Native Feel | Dev Experience |
|-----------|-------------|--------|-------------|----------------|
| **Tauri** | ~3MB | Low | Excellent | Rust + Web |
| Electron | ~150MB | High | Good | JS everywhere |
| Wails | ~10MB | Medium | Good | Go + Web |
| Native | Smallest | Lowest | Best | Platform-specific |

**Tauri advantages for nous:**
- Rust backend = easy integration with tmux, git, filesystem
- Web frontend = beautiful UI with React/Svelte
- Tiny bundle size (matters for Nix packaging)
- Native system integration (notifications, tray, menus)
- Multi-window support out of the box
- Active development, modern tooling

### Recommended Stack

```
Frontend:
  - React 19 (familiar, huge ecosystem)
  - Tailwind CSS (rapid styling)
  - Framer Motion (buttery animations)
  - xterm.js (embedded terminals)
  - Monaco Editor (code/diff viewing)
  - Zustand (lightweight state)

Backend (Rust):
  - tokio (async runtime)
  - tauri (app framework)
  - tmux-interface (tmux IPC)
  - notify (file watching)
  - git2 (git operations)
  - russh (SSH client)

IPC:
  - Tauri commands (Rust ↔ JS)
  - Custom events (real-time updates)
```

---

## Part 3: UI/UX Design Philosophy

### 100x Developer Experience Principles

1. **Keyboard-First, Mouse-Welcome**
   - Every action has a keyboard shortcut
   - Command palette (Cmd+K) for discovery
   - But also beautiful for trackpad users

2. **Information Density Done Right**
   - Show everything relevant, nothing more
   - Progressive disclosure for details
   - No clicks to see status

3. **Zero Latency Feel**
   - Optimistic UI updates
   - Background loading with skeletons
   - Instant keyboard response (<16ms)

4. **Context Preservation**
   - Sessions remember scroll position
   - Zoom level persists
   - Window positions restored

5. **Beautiful Defaults, Full Customization**
   - Gorgeous out of the box
   - Theme system (dark/light/custom)
   - Layout presets + custom arrangements

### Visual Design Language

**Theme: "Deep Space"** (evolved from deep-blue)

```css
/* Core palette */
--bg-primary: #0d1117;
--bg-secondary: #161b22;
--bg-elevated: #21262d;
--border: #30363d;

/* Accent colors (session states) */
--active: #58a6ff;      /* Cyan blue - active/thinking */
--success: #3fb950;     /* Green - completed action */
--warning: #d29922;     /* Amber - waiting for input */
--error: #f85149;       /* Red - error state */
--idle: #6e7681;        /* Gray - idle/inactive */

/* Text hierarchy */
--text-primary: #e6edf3;
--text-secondary: #8b949e;
--text-muted: #6e7681;

/* Syntax (for diffs) */
--diff-add: #1f6feb20;
--diff-remove: #f8514920;
```

---

## Part 4: Screen Designs

### 4.1 Main Dashboard

The hub. Everything at a glance.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ● ○ ○                            nous                               ⚡ ⚙    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─ SESSIONS ──────────────────────────┐  ┌─ ACTIVITY ───────────────────┐  │
│  │                                      │  │                              │  │
│  │  ▾ frontend                    (2)   │  │  12:34:02                    │  │
│  │    ● ui-refactor         3m ◉ 7     │  │    ● ui-refactor             │  │
│  │    ○ styling            12m   2      │  │      M Button.tsx     +42    │  │
│  │                                      │  │      M Modal.tsx      +28    │  │
│  │  ▾ backend                     (1)   │  │                              │  │
│  │    ● api-work            1m ◉ 3     │  │  12:33:58                    │  │
│  │                                      │  │    ● api-work                │  │
│  │  ▸ infra                       (2)   │  │      M auth.ts         +15   │  │
│  │                                      │  │                              │  │
│  │  ○ scratch              2h    0      │  │  12:33:12                    │  │
│  │                                      │  │    ○ styling                 │  │
│  │                                      │  │      M theme.css       +23   │  │
│  │                                      │  │                              │  │
│  │  ─────────────────────────────────── │  │                              │  │
│  │  + New session          ⌘N          │  │                              │  │
│  └──────────────────────────────────────┘  └──────────────────────────────┘  │
│                                                                             │
│  ┌─ PREVIEW ─────────────────────────────────────────────────────────────┐  │
│  │                                                                        │  │
│  │  │ ui-refactor                                              ▭ ⊞ ✕    │  │
│  │  │                                                                     │  │
│  │  │ Claude: I'll add a ripple effect to the Button component...        │  │
│  │  │                                                                     │  │
│  │  │ ┌─ Edit: src/components/Button.tsx ────────────────────────────┐   │  │
│  │  │ │  @@ -23,7 +23,12 @@                                          │   │  │
│  │  │ │   export function Button({ variant, ...props }) {            │   │  │
│  │  │ │ -   return <button>{children}</button>                       │   │  │
│  │  │ │ +   const ripple = useRipple();                              │   │  │
│  │  │ │ +   return (                                                 │   │  │
│  │  │ │ +     <button onMouseDown={ripple.trigger}>                  │   │  │
│  │  │ │ +       {ripple.element}                                     │   │  │
│  │  │ │ +       {children}                                           │   │  │
│  │  │ │ +     </button>                                              │   │  │
│  │  │ │ +   );                                                       │   │  │
│  │  │ └──────────────────────────────────────────────────────────────┘   │  │
│  │  │                                                                     │  │
│  │  │ > _                                                          Send │  │
│  │  │                                                                     │  │
│  └──────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ ⌘K Command   │ j/k Navigate   Enter Focus   n New   ? Help   4 active · 7  │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Features:**
- Session list with groups, status, file count badges
- Activity stream showing real-time changes
- Inline session preview with embedded terminal
- Quick actions in footer
- Status bar with counts

### 4.2 Session Focus (Full Terminal View)

When you need to see the full session.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ● ○ ○           nous › ui-refactor                     ⟲ ⊞ ◧ ◨ ⚙    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                                                                         ││
│  │  Claude: I'll add a ripple effect to the Button component. Let me      ││
│  │  modify the implementation:                                             ││
│  │                                                                         ││
│  │  ┌─ Edit: src/components/Button.tsx ────────────────────────────────┐  ││
│  │  │  @@ -23,7 +23,12 @@                                              │  ││
│  │  │   export function Button({ variant, children, ...props }) {      │  ││
│  │  │     const theme = useTheme();                                    │  ││
│  │  │  -  return <button className={styles}>{children}</button>        │  ││
│  │  │  +  const ripple = useRipple();                                  │  ││
│  │  │  +                                                               │  ││
│  │  │  +  return (                                                     │  ││
│  │  │  +    <button                                                    │  ││
│  │  │  +      className={cn(styles, variant)}                          │  ││
│  │  │  +      onMouseDown={ripple.trigger}                             │  ││
│  │  │  +      {...props}                                               │  ││
│  │  │  +    >                                                          │  ││
│  │  │  +      {ripple.element}                                         │  ││
│  │  │  +      {children}                                               │  ││
│  │  │  +    </button>                                                  │  ││
│  │  │  +  );                                                           │  ││
│  │  │   }                                                              │  ││
│  │  └──────────────────────────────────────────────────────────────────┘  ││
│  │                                                                         ││
│  │  I've added the ripple effect. Would you like me to also create the    ││
│  │  useRipple hook, or do you have an existing implementation?             ││
│  │                                                                         ││
│  │  > _                                                                    ││
│  │                                                                         ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
├───────────────────────┬───────────────────────────────────────────────────┬─┤
│  FILES CHANGED (7)    │                                                   │ │
│ ─────────────────────┤│  ~/projects/app                                   │ │
│  src/components/      ││  Branch: feature/button-ripple                   │ │
│    M Button.tsx  +42  ││  Started: 2h 34m ago                             │ │
│    M Modal.tsx   +28  ││  Status: ● active (thinking)                     │ │
│    A Dialog.tsx +156  ││  ─────────────────────────────────────           │ │
│  src/hooks/           ││  ⌘Enter Send   Esc Back   d Diff   c Commit     │ │
│    A useRipple   +45  ││                                                   │ │
└───────────────────────┴───────────────────────────────────────────────────┴─┘
```

**Key Features:**
- Full terminal/conversation view
- Sidebar with changed files (clickable)
- Session metadata panel
- Can be popped out to separate window
- Supports split view (multiple sessions side-by-side)

### 4.3 Diff View

Beautiful, syntax-highlighted diffs.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ● ○ ○           nous › diff › ui-refactor                     ◧ ◨ ⚙    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─ FILES (7) ─────────┐  ┌─ src/components/Button.tsx ──────────────────┐ │
│  │                      │  │                                              │ │
│  │  src/components/     │  │  @@ -23,7 +23,18 @@                         │ │
│  │  ● Button.tsx   +42  │  │                                              │ │
│  │    Modal.tsx    +28  │  │  23   export function Button({ variant,      │ │
│  │    Dialog.tsx  +156  │  │  24     children,                            │ │
│  │    index.ts      +3  │  │  25     ...props                             │ │
│  │                      │  │  26   }) {                                   │ │
│  │  src/                │  │  27     const theme = useTheme();            │ │
│  │    App.tsx      +12  │  │  28 -   return (                             │ │
│  │                      │  │  29 -     <button className={styles}>        │ │
│  │  src/hooks/          │  │  30 -       {children}                       │ │
│  │    useRipple.ts +45  │  │  31 -     </button>                          │ │
│  │                      │  │  32 -   );                                   │ │
│  │  src/styles/         │  │  28 +   const ripple = useRipple();          │ │
│  │    components  +23   │  │  29 +                                        │ │
│  │                      │  │  30 +   return (                             │ │
│  │ ──────────────────── │  │  31 +     <button                            │ │
│  │ +309 -35 total       │  │  32 +       className={cn(styles, variant)}  │ │
│  │                      │  │  33 +       onMouseDown={ripple.trigger}     │ │
│  │ [ Stage All ]        │  │  34 +       {...props}                       │ │
│  │                      │  │  35 +     >                                  │ │
│  │                      │  │  36 +       {ripple.element}                 │ │
│  │                      │  │  37 +       {children}                       │ │
│  │                      │  │  38 +     </button>                          │ │
│  │                      │  │  39 +   );                                   │ │
│  │                      │  │  40   }                                      │ │
│  └──────────────────────┘  └──────────────────────────────────────────────┘ │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ j/k Files   J/K Hunks   s Stage   u Unstage   o Open in Editor   Esc Back  │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Features:**
- Monaco-powered diff viewer
- Side-by-side or unified view toggle
- Syntax highlighting
- Line-level staging (like VS Code)
- Jump between hunks

### 4.4 Command Palette

Quick access to everything.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                                                                             │
│     ┌─────────────────────────────────────────────────────────────────┐     │
│     │ > new session frontend                                          │     │
│     ├─────────────────────────────────────────────────────────────────┤     │
│     │                                                                 │     │
│     │  ● New Session in frontend group              ⌘N               │     │
│     │    Create a new Claude session                                  │     │
│     │                                                                 │     │
│     │  ○ New Session                                ⌘⇧N              │     │
│     │    Create session with custom settings                          │     │
│     │                                                                 │     │
│     │  ○ Focus: ui-refactor (frontend)              ⌘1               │     │
│     │    Jump to this session                                         │     │
│     │                                                                 │     │
│     │  ○ Focus: styling (frontend)                  ⌘2               │     │
│     │    Jump to this session                                         │     │
│     │                                                                 │     │
│     └─────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.5 Multi-Window Layout

For large monitors or multi-monitor setups.

```
┌─────────────────────────────────┐  ┌─────────────────────────────────┐
│  ● ○ ○    ui-refactor          │  │  ● ○ ○    api-work             │
├─────────────────────────────────┤  ├─────────────────────────────────┤
│                                 │  │                                 │
│  Claude: I'll refactor...       │  │  Claude: The auth endpoint...   │
│                                 │  │                                 │
│  ┌─ Edit: Button.tsx ────────┐  │  │  ┌─ Edit: auth.ts ───────────┐  │
│  │  - return <button>        │  │  │  │  + validateToken(token)   │  │
│  │  + const ripple = ...     │  │  │  │  + return { user, token } │  │
│  └───────────────────────────┘  │  │  └───────────────────────────┘  │
│                                 │  │                                 │
│  > _                            │  │  > _                            │
└─────────────────────────────────┘  └─────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────┐
│  ● ○ ○    nous › dashboard                                           │
├───────────────────────────────────────────────────────────────────────┤
│  SESSIONS              │  ACTIVITY              │  SERVERS            │
│  ────────────────────  │  ────────────────────  │  ──────────────────│
│  ● ui-refactor    3m   │  12:34 Button.tsx     │  ● local      4    │
│  ● api-work       1m   │  12:33 auth.ts        │  ● hetzner    2    │
│  ○ styling       12m   │  12:32 theme.css      │  ○ nixos-vm   0    │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Part 5: Key Features Deep Dive

### 5.1 Embedded Terminal (xterm.js)

Each session gets an embedded terminal that shows the Claude Code conversation.

**Implementation:**
```typescript
// Terminal component with xterm.js
const SessionTerminal: FC<{ sessionId: string }> = ({ sessionId }) => {
  const termRef = useRef<Terminal>();

  useEffect(() => {
    const term = new Terminal({
      theme: deepSpaceTheme,
      fontFamily: 'JetBrains Mono, monospace',
      fontSize: 13,
      cursorBlink: true,
    });

    // Attach to tmux pane output via Tauri backend
    const unlisten = listen(`session:${sessionId}:output`, (event) => {
      term.write(event.payload);
    });

    return () => unlisten();
  }, [sessionId]);

  return <div ref={termRef} className="terminal-container" />;
};
```

**Key capabilities:**
- Real-time output streaming from tmux
- Input forwarding to tmux pane
- Copy/paste support
- Search within terminal
- Scrollback buffer
- Link detection

### 5.2 File System Watcher

Real-time tracking of what each session modifies.

**Backend (Rust):**
```rust
use notify::{Watcher, RecursiveMode, watcher};

pub struct FileWatcher {
    sessions: HashMap<String, PathBuf>,
    watcher: RecommendedWatcher,
}

impl FileWatcher {
    pub fn watch_session(&mut self, id: &str, dir: PathBuf) {
        self.watcher.watch(&dir, RecursiveMode::Recursive)?;
        self.sessions.insert(id.to_string(), dir);
    }

    fn handle_event(&self, event: Event) -> Option<FileChange> {
        // Attribute change to session based on directory
        for (id, dir) in &self.sessions {
            if event.path.starts_with(dir) {
                return Some(FileChange {
                    session_id: id.clone(),
                    path: event.path,
                    kind: event.kind,
                    timestamp: Instant::now(),
                });
            }
        }
        None
    }
}
```

### 5.3 Git Integration

Deep integration for staging, committing, and viewing diffs.

```rust
use git2::Repository;

pub fn get_session_diff(session_dir: &Path) -> Result<Vec<FileDiff>> {
    let repo = Repository::discover(session_dir)?;
    let diff = repo.diff_index_to_workdir(None, None)?;

    diff.deltas().map(|delta| {
        FileDiff {
            path: delta.new_file().path().unwrap().to_owned(),
            status: delta.status(),
            additions: count_additions(&delta),
            deletions: count_deletions(&delta),
        }
    }).collect()
}

pub fn stage_file(session_dir: &Path, file: &Path) -> Result<()> {
    let repo = Repository::discover(session_dir)?;
    let mut index = repo.index()?;
    index.add_path(file)?;
    index.write()?;
    Ok(())
}
```

### 5.4 Multi-Server Support

SSH tunnels to remote agents, aggregated in the UI.

```
┌──────────────┐         SSH Tunnel         ┌──────────────┐
│  nous GUI    │ ◄─────────────────────────► │  nous-agent  │
│   (local)    │                             │  (hetzner)   │
│              │         SSH Tunnel         ├──────────────┤
│              │ ◄─────────────────────────► │  nous-agent  │
│              │                             │  (nixos-vm)  │
└──────────────┘                             └──────────────┘
```

**Agent Protocol:**
```json
// Request
{ "type": "list_sessions" }

// Response
{
  "type": "sessions",
  "data": [
    {
      "id": "abc123",
      "name": "blog-updates",
      "working_dir": "/home/claude/the-blog",
      "status": "active",
      "pane": "nous:1.2"
    }
  ]
}

// Event (pushed)
{
  "type": "file_change",
  "session_id": "abc123",
  "path": "content/posts/new.md",
  "kind": "modify"
}
```

### 5.5 Notifications

Native system notifications for important events.

```rust
use tauri::api::notification::Notification;

pub fn notify_session_waiting(session: &Session) {
    Notification::new("nous")
        .title(&format!("{} needs input", session.name))
        .body("Claude is waiting for your response")
        .icon("nous-icon")
        .show()?;
}

pub fn notify_task_complete(session: &Session) {
    Notification::new("nous")
        .title(&format!("{} completed", session.name))
        .body("Claude has finished the current task")
        .show()?;
}
```

---

## Part 6: Keyboard Shortcuts

### Global (always available)
| Shortcut | Action |
|----------|--------|
| `⌘K` | Command palette |
| `⌘N` | New session |
| `⌘W` | Close current pane/window |
| `⌘1-9` | Jump to session by index |
| `⌘,` | Settings |
| `⌘⇧P` | Toggle preview pane |
| `⌘⇧D` | Toggle diff view |

### Navigation
| Shortcut | Action |
|----------|--------|
| `j` / `k` | Move up/down in lists |
| `h` / `l` | Collapse/expand groups |
| `g` `g` | Jump to top |
| `G` | Jump to bottom |
| `Tab` | Cycle focus between panels |
| `Esc` | Back / close modal |
| `/` | Search/filter |

### Sessions
| Shortcut | Action |
|----------|--------|
| `Enter` | Focus selected session (full view) |
| `Space` | Preview session (inline) |
| `n` | New session |
| `N` | New session in same directory |
| `x` | Kill session (with confirmation) |
| `r` | Rename session |

### Diff & Git
| Shortcut | Action |
|----------|--------|
| `d` | Show diff for session |
| `s` | Stage file |
| `S` | Stage all |
| `u` | Unstage file |
| `c` | Commit |
| `J` / `K` | Next/prev hunk |
| `o` | Open file in editor |

### Windows
| Shortcut | Action |
|----------|--------|
| `⌘⇧N` | New window |
| `⌘⇧\` | Split view |
| `⌘⇧]` / `[` | Next/prev tab |
| `⌘⌥→` / `←` | Move session to split |

---

## Part 7: Implementation Phases

### Phase 0: Foundation (Week 1-2)
- [ ] Tauri project setup with React
- [ ] Basic tmux integration (list sessions, focus pane)
- [ ] Simple session list view
- [ ] Keyboard navigation (j/k, Enter)
- [ ] Command palette skeleton

**Milestone:** Can list and switch between sessions

### Phase 1: Core Dashboard (Week 3-4)
- [ ] Full dashboard layout
- [ ] Session groups (collapsible)
- [ ] File watcher integration
- [ ] Activity stream
- [ ] Real-time updates

**Milestone:** Dashboard shows live session activity

### Phase 2: Session View (Week 5-6)
- [ ] Embedded terminal (xterm.js)
- [ ] Terminal ↔ tmux pane connection
- [ ] Input forwarding
- [ ] Session metadata sidebar
- [ ] Pop-out to window

**Milestone:** Can interact with sessions in GUI

### Phase 3: Diff Integration (Week 7-8)
- [ ] Git diff via Rust backend
- [ ] Monaco diff viewer
- [ ] File staging
- [ ] Commit dialog
- [ ] Hunk navigation

**Milestone:** Full git workflow in GUI

### Phase 4: Multi-Server (Week 9-10)
- [ ] Agent binary (Rust)
- [ ] SSH tunnel manager
- [ ] Server connection UI
- [ ] Cross-server activity stream
- [ ] Graceful disconnect handling

**Milestone:** Can manage sessions across machines

### Phase 5: Polish (Week 11-12)
- [ ] Animations (Framer Motion)
- [ ] Themes (light/dark/custom)
- [ ] Settings UI
- [ ] Onboarding flow
- [ ] Error handling
- [ ] Nix packaging

**Milestone:** Production-ready release

### Phase 6: Mobile Companion (Future)
- [ ] React Native or PWA
- [ ] Session monitoring
- [ ] Push notifications
- [ ] Quick actions

---

## Part 8: Critical Commands to Add

Based on the existing commands, here are essential additions:

### Session Management
| Command | Description |
|---------|-------------|
| `rename` | Rename session (not just pane title) |
| `clone` | Duplicate session config in new pane |
| `suspend` | Pause session (stop polling) |
| `archive` | Move to archive, preserve history |

### Git Integration
| Command | Description |
|---------|-------------|
| `commit` | Commit current session's changes |
| `stage` | Stage specific file |
| `diff` | Show diff view |
| `branch` | Create branch from session changes |

### Multi-Server
| Command | Description |
|---------|-------------|
| `connect` | Connect to remote server |
| `disconnect` | Disconnect from server |
| `deploy` | Trigger nix deployment |
| `sync` | Show config sync status |

### Navigation
| Command | Description |
|---------|-------------|
| `search` | Fuzzy find sessions/files |
| `goto` | Jump to session by name |
| `recent` | Show recently closed sessions |

---

## Part 9: Data Model Updates

```typescript
interface Session {
  id: string;
  name: string;
  paneId: string;
  workingDir: string;

  // New fields
  server: 'local' | string;          // Server name
  group: string | null;              // Group assignment
  status: 'active' | 'idle' | 'waiting' | 'error';
  startedAt: Date;
  lastActivity: Date;

  // Computed from file watcher
  changedFiles: number;
  additions: number;
  deletions: number;
}

interface FileChange {
  sessionId: string;
  timestamp: Date;
  path: string;
  kind: 'add' | 'modify' | 'delete';
  diff?: string;  // Cached diff content
}

interface Server {
  name: string;
  host: string;
  user: string;
  status: 'connected' | 'disconnected' | 'connecting' | 'error';
  sessions: Session[];
  latency?: number;
}

interface Group {
  name: string;
  color: string;
  autoAssign?: string[];  // Directory patterns
}
```

---

## Part 10: Nix Packaging

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
        in {
          default = pkgs.callPackage ./package.nix { };
          nous-agent = pkgs.callPackage ./agent.nix { };
        }
      );

      homeManagerModules.default = import ./hm-module.nix;
    };
}
```

```nix
# hm-module.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.programs.nous;
in {
  options.programs.nous = {
    enable = mkEnableOption "nous - Claude Code orchestrator";

    servers = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          host = mkOption { type = types.str; };
          user = mkOption { type = types.str; default = "claude"; };
        };
      });
      default = {};
    };

    groups = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          color = mkOption { type = types.str; };
          directories = mkOption { type = types.listOf types.str; default = []; };
        };
      });
      default = {};
    };

    theme = mkOption {
      type = types.enum [ "dark" "light" "system" ];
      default = "dark";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nous ];

    xdg.configFile."nous/config.toml".text = ''
      theme = "${cfg.theme}"

      ${concatStringsSep "\n" (mapAttrsToList (name: server: ''
        [servers.${name}]
        host = "${server.host}"
        user = "${server.user}"
      '') cfg.servers)}

      ${concatStringsSep "\n" (mapAttrsToList (name: group: ''
        [groups.${name}]
        color = "${group.color}"
        directories = [${concatMapStringsSep ", " (d: "\"${d}\"") group.directories}]
      '') cfg.groups)}
    '';
  };
}
```

---

## Part 11: Open Questions

### Answered by This Plan
- [x] GUI framework: Tauri (Rust + React)
- [x] Keep tmux: Yes, as session backend
- [x] Terminal embedding: xterm.js

### Still Open
- [ ] Should we support Windows? (Tauri does, but tmux doesn't)
- [ ] How deep should Claude conversation parsing go?
- [ ] Should we support vim-mode in the GUI terminal?
- [ ] Local-first vs sync across machines?
- [ ] Plugin/extension system?

---

## Part 12: Success Criteria

**v1.0 is ready when:**

1. **Session Management**
   - [ ] Can list all local sessions
   - [ ] Can create, rename, kill sessions
   - [ ] Sessions grouped and filterable
   - [ ] Status visible at a glance

2. **Developer Experience**
   - [ ] Every action < 100ms response
   - [ ] Keyboard shortcuts work everywhere
   - [ ] Command palette finds everything
   - [ ] No mouse required for any workflow

3. **Git Integration**
   - [ ] See file changes per session
   - [ ] View diffs with syntax highlighting
   - [ ] Stage, unstage, commit from GUI
   - [ ] Open files in external editor

4. **Multi-Server**
   - [ ] Connect to remote servers
   - [ ] Unified session view
   - [ ] Cross-server activity stream
   - [ ] Graceful offline handling

5. **Polish**
   - [ ] Beautiful dark theme
   - [ ] Smooth animations
   - [ ] Native notifications
   - [ ] Works on macOS and Linux

---

## Next Steps

1. **Spike: Tauri + xterm.js** - Verify terminal embedding works
2. **Spike: Rust tmux bindings** - Test session management
3. **Design: Component library** - Build reusable UI pieces
4. **MVP: Dashboard only** - Just the left panel working

The existing TUI can continue to work alongside the GUI during development. Users can choose which interface they prefer.
