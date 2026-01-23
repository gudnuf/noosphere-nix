# Nous: Claude Code Session Orchestrator

A Bun-powered TUI for managing multiple Claude Code sessions across local and remote servers.

## Vision

Nous wraps the Claude Code CLI to provide:
- **Multi-session tracking** across tmux panes and remote servers
- **Real-time file change monitoring** per session
- **Clickable navigation** from file changes to editor/explorer
- **Configurable session groups** for organizing work
- **Cross-server deployment** with config sync status

The name "nous" (Greek: νοῦς) means "mind" or "intellect" - the coordinating intelligence across distributed Claude instances.

## Core Priorities

1. **Session Navigation** (Primary) - Fast switching between Claude sessions
2. **File Change Tracking** (Secondary) - See what each Claude is modifying
3. **Server Management** (Tertiary) - Coordinate across multiple machines

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   nous (local)  │────▶│  nous (hetzner) │     │  nous (nixos-vm)│
│                 │◀────│                 │     │                 │
│  coordinator    │     │  agent          │     │  agent          │
│  + TUI          │     │  + file watch   │     │  + file watch   │
│  + state DB     │     │  + session mgmt │     │  + session mgmt │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                    WebSocket / SSH tunnel
```

### Components

| Component | Role | Location |
|-----------|------|----------|
| Coordinator | TUI, state aggregation, user interaction | Local machine |
| Agent | File watching, session management, reporting | Each server |
| State DB | Session history, groups, preferences | SQLite (local) |
| Transport | Communication between coordinator and agents | SSH tunnel or WebSocket |

## Data Model

```typescript
interface Session {
  id: string;
  name: string;
  pid: number;
  tmuxPane: string;        // e.g., "main:1.2"
  workingDir: string;
  group: string | null;
  server: string;          // "local" or server name
  startedAt: Date;
  lastActivity: Date;
  status: 'active' | 'idle' | 'waiting';
}

interface FileChange {
  sessionId: string;
  timestamp: Date;
  path: string;
  type: 'add' | 'modify' | 'delete';
  diff?: string;
}

interface Group {
  name: string;
  color: string;
  sessions: string[];
  autoAssign?: {
    directories: string[];
  };
}

interface Server {
  name: string;
  host: string;
  user: string;
  status: 'connected' | 'disconnected' | 'connecting';
  latency?: number;
  sessions: Session[];
}
```

## TUI Screens

### Main Dashboard
Primary view showing session list and activity stream side-by-side.

### Session Focus
Detailed view of a single session: metadata, files changed, recent actions.

### Diff View
Split view with file list and diff content. Delta-style rendering.

### Group Management
CRUD for groups, auto-assign rules, session assignment.

### New Session
Form for creating sessions with name, directory, group, server, layout options.

### Servers Overview
List of configured servers with connection status and session counts.

### Cross-Server Activity
Unified activity stream across all connected servers.

### Deploy View
Pending deployments, config diffs, closure changes, deployment log.

### Search
Fuzzy search across sessions and files.

See `SCREENS.md` for full ASCII mockups of each screen.

## Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `j/k` | Move up/down |
| `J/K` | Move between groups |
| `h/l` | Collapse/expand |
| `gg` | Go to top |
| `G` | Go to bottom |
| `Tab` | Cycle panels |
| `Esc` | Back/close |
| `/` | Search |
| `?` | Help |

### Sessions
| Key | Action |
|-----|--------|
| `n` | New session |
| `Enter` | Focus session (jump to pane) |
| `Space` | Preview session |
| `k` | Kill session |
| `r` | Rename session |
| `c` | Commit session changes |

### Groups
| Key | Action |
|-----|--------|
| `ga` | Add to group |
| `gc` | Create group |
| `gd` | Delete group |
| `gr` | Rename group |

### Servers
| Key | Action |
|-----|--------|
| `S` | Servers view |
| `C` | Connect server |
| `D` | Deploy view |
| `R` | Refresh connections |

### Files
| Key | Action |
|-----|--------|
| `d` | Show diff |
| `s` | Stage file |
| `u` | Unstage file |
| `o` | Open in editor |
| `O` | Reveal in explorer |

## CLI Interface

```bash
# Launch TUI
nous

# Session management
nous new "task description"
nous new --group backend --dir ~/api "fix auth"
nous new --server hetzner --split-right "deploy blog"
nous list
nous kill <session-id>

# Server management
nous servers
nous connect <server-name>
nous disconnect <server-name>

# Deployment
nous deploy <server-name>
nous deploy --all
nous sync-status

# Groups
nous groups
nous groups create <name>
nous groups add <session-id> <group-name>
```

## Configuration

```nix
# home/modules/nous.nix
programs.nous = {
  enable = true;

  servers = {
    hetzner = {
      host = "77.42.27.244";
      user = "claude";
    };
    nixos-vm = {
      host = "nixos-vm.local";
      user = "claude";
    };
  };

  groups = {
    frontend = {
      color = "#89ddff";
      directories = [ "~/projects/app/src" ];
    };
    backend = {
      color = "#c3e88d";
      directories = [ "~/projects/api" ];
    };
    infra = {
      color = "#ffcb6b";
      directories = [ "~/.config/nix-config" "~/noosphere-nix" ];
    };
  };

  fileNavigation = {
    editor = "nvim";
    openCommand = "nvim +{line} {file}";
    revealCommand = "nvim -c 'Neotree reveal={file}'";
  };

  theme = "deep-blue";
};
```

## Open Questions

### Session Discovery
- [ ] How do we reliably detect Claude Code processes in tmux?
- [ ] Should we require sessions to be started via `nous new` or detect existing?
- [ ] How do we associate a file change with the correct session if directories overlap?

### File Watching
- [ ] What's the debounce interval for rapid changes?
- [ ] How do we handle large repos efficiently?
- [ ] Should we use git status or raw file system events?
- [ ] How do we detect which session caused a change in shared directories?

### Cross-Server Communication
- [ ] SSH tunnel vs WebSocket vs custom protocol?
- [ ] How do we handle intermittent connectivity?
- [ ] Should agents buffer changes when disconnected?
- [ ] Authentication: reuse SSH keys or separate auth?

### Deployment Integration
- [ ] How tightly do we integrate with nix-config deployment?
- [ ] Should nous trigger deploys or just show status?
- [ ] How do we detect what config a server is running?

### TUI Framework
- [ ] Ink (React-like) vs Blessed vs custom?
- [ ] How do we handle terminal resize?
- [ ] Mouse support priorities?

### State Management
- [ ] What belongs in SQLite vs in-memory?
- [ ] How long do we retain session history?
- [ ] Do we sync state across servers or keep local only?

## Areas for Further Brainstorming

### 1. Session Context Awareness
How much should nous understand about what each Claude is doing?
- Parse conversation for task summaries?
- Track which files Claude has read vs modified?
- Detect when Claude is waiting for input vs actively working?

### 2. Conflict Detection
When multiple Claudes touch the same file:
- Just warn, or actively prevent?
- Lock files per session?
- Show merge UI?

### 3. Git Integration Depth
- Stage/commit from within nous?
- Branch-per-session workflows?
- Auto-stash when switching sessions?

### 4. Notification System
- Desktop notifications for completed tasks?
- Sound alerts?
- Integration with system notification center?

### 5. Session Templates
- Predefined configurations for common tasks?
- "Review PR" template with specific MCP servers?
- Project-specific defaults?

### 6. History and Search
- Full-text search of past sessions?
- "What did we decide about X?"
- Session summaries on exit?

### 7. Resource Monitoring
- Token usage per session?
- Cost tracking?
- Rate limit awareness?

### 8. Plugin System
- Hook system for custom behavior?
- Community plugins?
- Per-project plugins?

## Implementation Phases

### Phase 1: Local Foundation
- [ ] Basic Bun project structure
- [ ] Tmux session discovery
- [ ] Simple TUI with session list
- [ ] Navigate and focus sessions

### Phase 2: File Tracking
- [ ] File watcher per session directory
- [ ] Activity stream display
- [ ] OSC 8 clickable file paths
- [ ] Basic diff preview

### Phase 3: Groups and Views
- [ ] Group CRUD
- [ ] Auto-assign rules
- [ ] View filters
- [ ] Persistent config

### Phase 4: Multi-Server
- [ ] Agent binary
- [ ] SSH tunnel communication
- [ ] Server connection management
- [ ] Cross-server activity view

### Phase 5: Deployment
- [ ] Config sync status
- [ ] Deploy preview
- [ ] Deploy execution
- [ ] Deployment history

### Phase 6: Polish
- [ ] Nix packaging
- [ ] Deep blue theme
- [ ] Full keybinding customization
- [ ] Documentation

## Next Steps

See `ITERATION.md` for the step-by-step iteration process.
