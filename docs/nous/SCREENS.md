# Nous: TUI Screen Mockups

All screens follow a consistent layout:
- Header: app name, current view, server indicator
- Main content area (varies by screen)
- Footer: contextual keybindings

Color palette (deep blue theme):
- Background: `#1a1d2e`, `#1e2030`
- Borders: `#3b3f5f`
- Accent: `#89ddff` (cyan), `#c3e88d` (green), `#ffcb6b` (yellow), `#ff757f` (red)
- Text: `#cdd6f4`, `#6b7086` (muted)

---

## 1. Main Dashboard

The primary view. Session list on left, activity stream on right.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous                                                      nous.local    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  SESSIONS                            ACTIVITY                           │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  ▸ frontend (2)                      12:34:02 ● ui-refactor             │
│    ● ui-refactor        3m ago         M src/components/Button.tsx      │
│    ○ styling           12m ago         M src/components/Modal.tsx       │
│                                        A src/components/Dialog.tsx      │
│  ▸ backend (1)                                                          │
│    ● api-work           1m ago       12:33:58 ● api-work                │
│                                        M server/routes/auth.ts          │
│  ▸ infra (1)                                                            │
│    ○ nix-config        45m ago       12:33:12 ○ styling                 │
│                                        M src/styles/theme.css           │
│  ○ scratch              2h ago                                          │
│                                      12:30:45 ● ui-refactor             │
│                                        M src/App.tsx                    │
│                                                                         │
│                                                                         │
│  4 active · 1 idle · 12 files changed                                   │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ j/k navigate  Enter focus  g groups  d diff  n new  / search  ? help   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Session list**: Hierarchical by group, collapsible
- **Status indicators**: `●` active, `○` idle
- **Time ago**: Relative timestamp of last activity
- **Activity stream**: Real-time file changes, newest at top
- **File indicators**: `M` modify, `A` add, `D` delete
- **Stats bar**: Quick counts

---

## 2. Session Focus View

Detailed view when you select a session.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › ui-refactor                                        nous.local    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  SESSION                             FILES CHANGED (7)                  │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  Name:      ui-refactor              src/components/                    │
│  Group:     frontend                   M Button.tsx          +42 -18   │
│  Directory: ~/projects/app             M Modal.tsx           +28 -3    │
│  Started:   2h 34m ago                 A Dialog.tsx          +156      │
│  Status:    ● active                   M index.ts            +3  -1    │
│  Pane:      main:1.2                                                   │
│                                      src/                               │
│  RECENT ACTIONS                        M App.tsx             +12 -8    │
│  ─────────────────────────────────                                     │
│                                      src/hooks/                         │
│  • Modified Button component           M useDialog.ts        +45       │
│  • Created Dialog component                                            │
│  • Updated Modal animations          src/styles/                        │
│  • Refactored shared hooks             M components.css      +23 -5    │
│                                                                         │
│                                                                         │
│                                      ─────────────────────────────────  │
│                                      Total: +309 -35 lines              │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Enter jump to pane  d diff all  f filter files  c commit  Esc back     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Session metadata**: Name, group, directory, timing, tmux pane
- **Recent actions**: Parsed from Claude's output (stretch goal)
- **Files changed**: Grouped by directory, with line counts
- **Total stats**: Aggregate insertions/deletions

---

## 3. Diff View

Split view for reviewing changes.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › diff › ui-refactor                                 nous.local    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  FILES (7)                 │ src/components/Button.tsx                  │
│  ──────────────────────────│────────────────────────────────────────    │
│                            │                                            │
│  src/components/           │  @@ -23,7 +23,12 @@                        │
│  ● Button.tsx        +42   │   export function Button({ variant, ...    │
│    Modal.tsx         +28   │     const theme = useTheme();              │
│    Dialog.tsx       +156   │  -  return <button className={styles}...   │
│    index.ts           +3   │  +  const ripple = useRipple();            │
│                            │  +                                         │
│  src/                      │  +  return (                               │
│    App.tsx           +12   │  +    <button                              │
│                            │  +      className={cn(styles, variant)}    │
│  src/hooks/                │  +      onMouseDown={ripple.trigger}       │
│    useDialog.ts      +45   │  +      {...props}                         │
│                            │  +    >                                    │
│  src/styles/               │  +      {ripple.element}                   │
│    components.css    +23   │  +      {children}                         │
│                            │  +    </button>                            │
│                            │  +  );                                     │
│                            │   }                                        │
│                            │                                            │
├─────────────────────────────────────────────────────────────────────────┤
│ j/k files  J/K hunks  Enter open file  s stage  S stage all  Esc back  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **File list**: Left panel, selected file highlighted
- **Diff content**: Right panel, delta-style syntax highlighting
- **Hunk navigation**: Move between diff sections
- **Staging**: Git integration for staging files

---

## 4. Group Management

CRUD operations for groups.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › groups                                             nous.local    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  GROUPS                              SESSIONS IN "frontend"             │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  ● frontend         2 sessions       ● ui-refactor                      │
│    backend          1 session          ~/projects/app                   │
│    infra            1 session          3m ago · 7 files                 │
│    devops           0 sessions                                          │
│                                      ○ styling                          │
│                                        ~/projects/app                   │
│  ─────────────────────────────────     12m ago · 2 files                │
│                                                                         │
│  AUTO-ASSIGN RULES                                                      │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  ~/projects/app     → frontend       ACTIONS                            │
│  ~/projects/api     → backend                                           │
│  ~/.config/nix-*    → infra          a  add session to group            │
│                                      r  remove session                  │
│                                      e  edit auto-assign rules          │
│                                      c  change group color              │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ j/k navigate  Enter select  n new group  d delete  e edit  Esc back    │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Group list**: With session counts
- **Selected group details**: Sessions in that group
- **Auto-assign rules**: Directory → group mappings
- **Action hints**: Contextual operations

---

## 5. New Session

Modal form for creating sessions.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › new session                                        nous.local    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│                                                                         │
│     ┌─────────────────────────────────────────────────────────────┐     │
│     │                                                             │     │
│     │  Name:       fix-auth-bug_____________________________      │     │
│     │                                                             │     │
│     │  Directory:  ~/projects/api___________________________      │     │
│     │              ▾ Recent                                       │     │
│     │                ~/projects/api                               │     │
│     │                ~/projects/app                               │     │
│     │                ~/.config/nix-config                         │     │
│     │                                                             │     │
│     │  Group:      ○ frontend  ● backend  ○ infra  ○ none         │     │
│     │                                                             │     │
│     │  Server:     ● local  ○ hetzner  ○ nixos-vm                 │     │
│     │                                                             │     │
│     │  Layout:     ○ current pane                                 │     │
│     │              ● split right                                  │     │
│     │              ○ split below                                  │     │
│     │              ○ new window                                   │     │
│     │                                                             │     │
│     │  Initial prompt (optional):                                 │     │
│     │  ┌─────────────────────────────────────────────────────┐    │     │
│     │  │ Fix the authentication bug in the login flow.      │    │     │
│     │  │ Users are getting logged out after 5 minutes.      │    │     │
│     │  └─────────────────────────────────────────────────────┘    │     │
│     │                                                             │     │
│     │                        [ Cancel ]  [ Create Session ]       │     │
│     │                                                             │     │
│     └─────────────────────────────────────────────────────────────┘     │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Tab next field  Shift+Tab prev  Enter submit  Esc cancel               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Text inputs**: Name, directory (with autocomplete)
- **Radio groups**: Group, server, layout
- **Text area**: Optional initial prompt
- **Buttons**: Cancel, Create

---

## 6. Servers Overview

View and manage connected servers.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › servers                                                          │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  SERVERS                             SERVER: hetzner                    │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  ● local (nous.local)                Host:     77.42.27.244             │
│    4 sessions · 12 files             User:     claude                   │
│                                      Status:   ● connected              │
│  ● hetzner                           Latency:  45ms                     │
│    2 sessions · 5 files              Uptime:   14d 3h 22m               │
│                                                                         │
│  ○ nixos-vm                          SESSIONS                           │
│    0 sessions · offline              ───────────────────────────────    │
│                                                                         │
│  ○ mynymbox                          ● blog-updates        12m ago      │
│    0 sessions · offline                ~/the-blog                       │
│                                        M content/posts/new-post.md      │
│                                        M src/templates/post.html        │
│                                                                         │
│                                      ○ server-config       1h ago       │
│                                        ~/noosphere-nix                  │
│                                        M hosts/hetzner/networking.nix   │
│                                                                         │
│                                                                         │
│  + Add server                                                           │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ j/k navigate  Enter select  n new session  c connect  d disconnect     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Server list**: With connection status and quick stats
- **Server details**: Host, user, status, latency, uptime
- **Server sessions**: Sessions running on selected server

---

## 7. Cross-Server Activity

Unified activity stream across all servers.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › all servers                                        4 connected   │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  ACTIVITY STREAM                                                        │
│  ───────────────────────────────────────────────────────────────────    │
│                                                                         │
│  12:45:02  local      ● ui-refactor                                     │
│              M src/components/Button.tsx                                │
│              M src/components/Modal.tsx                                 │
│                                                                         │
│  12:44:58  hetzner    ● blog-updates                                    │
│              M content/posts/building-nous.md                           │
│              A content/images/nous-screenshot.png                       │
│                                                                         │
│  12:44:45  local      ● api-work                                        │
│              M server/routes/auth.ts                                    │
│                                                                         │
│  12:44:30  hetzner    ○ server-config                                   │
│              M hosts/hetzner/networking.nix                             │
│                                                                         │
│  12:43:12  local      ● ui-refactor                                     │
│              A src/components/Dialog.tsx                                │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────      │
│  6 sessions across 2 servers · 18 files changed in last hour            │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ f filter by server  g filter by group  / search  Enter focus session   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Unified stream**: All changes, all servers, chronological
- **Server column**: Identifies source server
- **Filters**: By server, by group
- **Stats**: Aggregate counts

---

## 8. Server Connection

Modal for adding/editing server connections.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › connect server                                                   │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│                                                                         │
│     ┌─────────────────────────────────────────────────────────────┐     │
│     │                                                             │     │
│     │  CONNECT TO SERVER                                          │     │
│     │  ─────────────────────────────────────────────────────────  │     │
│     │                                                             │     │
│     │  Name:       hetzner______________________________          │     │
│     │                                                             │     │
│     │  Host:       77.42.27.244_________________________          │     │
│     │                                                             │     │
│     │  User:       claude_______________________________          │     │
│     │                                                             │     │
│     │  Auth:       ● SSH Key (1Password)                          │     │
│     │              ○ SSH Key (file)                               │     │
│     │              ○ Password                                     │     │
│     │                                                             │     │
│     │  ─────────────────────────────────────────────────────────  │     │
│     │                                                             │     │
│     │  Test connection...                    [ ● Connected ]      │     │
│     │                                                             │     │
│     │  Nous agent status:                    [ ● Running ]        │     │
│     │                                                             │     │
│     │                          [ Cancel ]  [ Save & Connect ]     │     │
│     │                                                             │     │
│     └─────────────────────────────────────────────────────────────┘     │
│                                                                         │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Tab next field  Enter submit  Esc cancel                               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Connection details**: Name, host, user
- **Auth method**: SSH key sources
- **Test indicators**: Connection and agent status
- **Actions**: Cancel, save

---

## 9. Deploy View

Deployment management.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › deploy                                                           │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  PENDING DEPLOYMENTS                 DEPLOYMENT LOG                     │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  ┌─ hetzner ──────────────────────   12:45:02 Building configuration... │
│  │                                   12:45:08 Copying to server...      │
│  │  Config: noosphere-nix#hetzner    12:45:23 Activating profile...     │
│  │  Changes:                         12:45:25 Running post-deploy...    │
│  │    M hosts/hetzner/networking.nix 12:45:26 ✓ Deploy complete         │
│  │    M flake.lock                                                      │
│  │                                   ─────────────────────────────────  │
│  │  From session: server-config                                         │
│  │  Status: ● ready to deploy        SERVICES AFFECTED                  │
│  │                                   ───────────────────────────────    │
│  └────────────────────────────────                                      │
│                                      • networking.service (restart)     │
│  ┌─ nixos-vm ─────────────────────   • nginx.service (reload)           │
│  │                                                                      │
│  │  Config: noosphere-nix#nixos-vm                                      │
│  │  Changes:                                                            │
│  │    M home/modules/dev-tools.nix                                      │
│  │                                                                      │
│  │  Status: ○ no connection                                             │
│  │                                                                      │
│  └────────────────────────────────                                      │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Enter deploy selected  a deploy all  p preview  l view log  Esc back   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Pending deployments**: Per-server cards with changes
- **Deployment log**: Real-time output
- **Services affected**: What will restart/reload
- **Actions**: Deploy, preview, view log

---

## 10. Deployment Preview

Diff preview before deploying.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › deploy › hetzner › preview                                       │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  CONFIGURATION DIFF                                                     │
│  ───────────────────────────────────────────────────────────────────    │
│                                                                         │
│  hosts/hetzner/networking.nix                                           │
│  ─────────────────────────────────────────────────────────────────      │
│   @@ -12,6 +12,10 @@                                                    │
│    networking = {                                                       │
│      hostName = "hetzner";                                              │
│      firewall = {                                                       │
│   -    allowedTCPPorts = [ 22 80 443 ];                                 │
│   +    allowedTCPPorts = [ 22 80 443 8080 ];                            │
│   +    allowedUDPPorts = [ 51820 ];  # wireguard                        │
│      };                                                                 │
│   +  wireguard.interfaces.wg0 = {                                       │
│   +    ips = [ "10.100.0.2/24" ];                                       │
│   +    privateKeyFile = "/etc/wireguard/private";                       │
│   +  };                                                                 │
│    };                                                                   │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────      │
│  CLOSURE DIFF                                                           │
│  ─────────────────────────────────────────────────────────────────      │
│  + wireguard-tools-1.0.20210914                                         │
│  • nixos-system-hetzner-24.11 → nixos-system-hetzner-24.11              │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Enter confirm deploy  d dry-run  Esc cancel                            │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Config diff**: What nix files changed
- **Closure diff**: What packages change
- **Dry-run option**: See what would happen

---

## 11. Search

Fuzzy search across sessions and files.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › search                                                           │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ > button_                                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  SESSIONS                            FILES                              │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  ● ui-refactor                       local › ui-refactor                │
│    "refactoring button components"     src/components/Button.tsx        │
│    local · frontend · 3m ago           src/components/IconButton.tsx    │
│                                        src/styles/button.css            │
│                                                                         │
│                                      local › styling                    │
│                                        src/styles/button-variants.css   │
│                                                                         │
│                                                                         │
│                                                                         │
│                                                                         │
│                                                                         │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────      │
│  1 session · 4 files matching "button"                                  │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Tab switch panel  Enter select  Ctrl+S sessions only  Ctrl+F files only│
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Search input**: Fuzzy matching
- **Split results**: Sessions and files
- **Quick filters**: Sessions only, files only

---

## 12. Session Log / Output

View a session's Claude output.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › ui-refactor › output                               nous.local    │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  12:45:02 ───────────────────────────────────────────────────────────   │
│                                                                         │
│  Claude: I'll refactor the Button component to support the new ripple   │
│  effect. Let me make these changes:                                     │
│                                                                         │
│  ┌─ Edit: src/components/Button.tsx ─────────────────────────────────┐  │
│  │  @@ -23,7 +23,12 @@                                               │  │
│  │   export function Button({ variant, ...props }) {                 │  │
│  │     const theme = useTheme();                                     │  │
│  │  -  return <button className={styles}>{children}</button>         │  │
│  │  +  const ripple = useRipple();                                   │  │
│  │  +  return (                                                      │  │
│  │  +    <button className={cn(styles, variant)} ...>                │  │
│  │  +      {ripple.element}                                          │  │
│  │  +      {children}                                                │  │
│  │  +    </button>                                                   │  │
│  │  +  );                                                            │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  12:45:08 ───────────────────────────────────────────────────────────   │
│                                                                         │
│  Claude: Now I'll create the useRipple hook...                          │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ j/k scroll  / search output  y yank block  Enter jump to pane  Esc back│
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Timestamped entries**: Scrollable log
- **Embedded diffs**: Rendered inline
- **Search**: Find in output
- **Yank**: Copy blocks to clipboard

---

## 13. Sync Status

Config synchronization across servers.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › sync                                                             │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  CONFIG SYNC STATUS                                                     │
│  ───────────────────────────────────────────────────────────────────    │
│                                                                         │
│  Repository: noosphere-nix                                              │
│  Branch:     enable-nix-experimental-features                           │
│                                                                         │
│  SERVER               LOCAL COMMIT      DEPLOYED COMMIT    STATUS       │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                         │
│  local (nous)         cc21829           cc21829            ✓ synced     │
│                                                                         │
│  hetzner              cc21829           2e3133e            ↑ 1 ahead    │
│                       enable-nix...     update: the-blog                │
│                                                                         │
│  nixos-vm             cc21829           0095977            ↑ 3 ahead    │
│                       enable-nix...     feat: integrate                 │
│                                                                         │
│  mynymbox             cc21829           —                  ○ offline    │
│                                                                         │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────      │
│  Last sync check: 2 minutes ago                                         │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Enter deploy  r refresh  a deploy all outdated  p pull on server       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Elements

- **Repo info**: Current branch
- **Server comparison**: Local vs deployed commits
- **Status indicators**: Synced, ahead, offline
- **Actions**: Deploy, refresh, batch deploy

---

## 14. Help

Keybinding reference.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ nous › help                                                             │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  NAVIGATION                          SESSIONS                           │
│  ─────────────────────────────────   ───────────────────────────────    │
│                                                                         │
│  j/k       move up/down              n         new session              │
│  J/K       move between groups       Enter     focus session (jump)     │
│  h/l       collapse/expand           Space     preview session          │
│  g g       go to top                 k         kill session             │
│  G         go to bottom              r         rename session           │
│  Tab       cycle panels              c         commit session changes   │
│  Esc       back / close                                                 │
│                                      SERVERS                            │
│  VIEWS                               ───────────────────────────────    │
│  ─────────────────────────────────                                      │
│                                      S         servers view             │
│  1         main dashboard            C         connect server           │
│  2         current group only        D         deploy view              │
│  3         all servers view          R         refresh connections      │
│  4         deploy view                                                  │
│  /         search                    FILES                              │
│  ?         this help                 ───────────────────────────────    │
│                                                                         │
│  GROUPS                              d         show diff                │
│  ─────────────────────────────────   s         stage file               │
│                                      u         unstage file             │
│  g a       add to group              o         open in editor           │
│  g c       create group              O         reveal in explorer       │
│  g d       delete group                                                 │
│  g r       rename group                                                 │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ Press any key to close                                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Screen Navigation Map

```
                              ┌──────────┐
                              │   Help   │
                              │   (?)    │
                              └────┬─────┘
                                   │
┌──────────┐    ┌──────────┐    ┌──┴───────┐    ┌──────────┐
│  Search  │◄───│   Main   │───►│ Servers  │───►│  Deploy  │
│   (/)    │    │Dashboard │    │   (S)    │    │   (D)    │
└──────────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘
                     │               │               │
                     ▼               ▼               ▼
               ┌──────────┐    ┌──────────┐    ┌──────────┐
               │ Session  │    │  Server  │    │  Deploy  │
               │  Focus   │    │ Connect  │    │ Preview  │
               └────┬─────┘    └──────────┘    └──────────┘
                    │
          ┌────────┬┴────────┐
          ▼        ▼         ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐
    │   Diff   │ │  Output  │ │  Groups  │
    │   (d)    │ │   (o)    │ │   (g)    │
    └──────────┘ └──────────┘ └──────────┘
```
