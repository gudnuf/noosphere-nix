# Nous: Mobile Experience

Design considerations for using nous via mobile SSH clients (Termius, Blink, etc).

## Constraints

| Constraint | Impact |
|------------|--------|
| Half screen is keyboard | ~15-20 visible lines max |
| Touch input | Tap targets need to be larger |
| No mouse hover | No tooltips, preview on hover |
| Limited typing | Minimize required keystrokes |
| Portrait orientation | Narrow width (~40-50 chars) |
| Thumb zone | Bottom of screen most accessible |
| Latency | SSH over cellular can be slow |

## Design Principles

1. **Vertical compression** - Show less, show what matters
2. **Touch-first** - Tap to select, swipe to navigate
3. **Minimal keystrokes** - Single-key actions, smart defaults
4. **Progressive disclosure** - Collapsed by default, expand on demand
5. **Thumb-friendly** - Important actions at bottom
6. **Offline-tolerant** - Handle connection drops gracefully

---

## Mobile Screens

### 1. Mobile Dashboard

Compressed single-column view. Sessions only, no activity stream.

```
┌─────────────────────────────┐
│ nous            ● 4 active  │
├─────────────────────────────┤
│                             │
│ ▸ frontend (2)              │
│   ● ui-refactor      3m ⟩   │
│   ○ styling         12m ⟩   │
│                             │
│ ▸ backend (1)               │
│   ● api-work         1m ⟩   │
│                             │
│ ○ scratch            2h ⟩   │
│                             │
├─────────────────────────────┤
│ [+]  [⌕]  [≡]  [↻]  [?]    │
└─────────────────────────────┘
     ↑ bottom action bar
```

**Elements:**
- Collapsed groups (tap to expand)
- Session rows are tap targets
- `⟩` indicates "tap for detail"
- Bottom bar: New, Search, Groups, Refresh, Help
- Status indicator in header

**Gestures:**
- Tap session → Session detail
- Tap group → Expand/collapse
- Swipe right on session → Quick focus (jump to pane)
- Swipe left on session → Quick actions menu
- Pull down → Refresh

---

### 2. Mobile Session Detail

Single session view with key info and actions.

```
┌─────────────────────────────┐
│ ← ui-refactor        ● 3m   │
├─────────────────────────────┤
│                             │
│ ~/projects/app              │
│ frontend · main:1.2         │
│                             │
│ FILES (7)            +309   │
│ ─────────────────────────── │
│ M Button.tsx         +42 ⟩  │
│ M Modal.tsx          +28 ⟩  │
│ A Dialog.tsx        +156 ⟩  │
│ M App.tsx            +12 ⟩  │
│   ↓ 3 more                  │
│                             │
├─────────────────────────────┤
│ [Focus]  [Diff]  [Commit]   │
└─────────────────────────────┘
```

**Elements:**
- Back arrow (tap or swipe right)
- Essential metadata only
- Truncated file list (tap to expand)
- Three primary actions

**Gestures:**
- Swipe right → Back to dashboard
- Tap file → File diff
- Tap "↓ 3 more" → Show all files

---

### 3. Mobile Activity Stream

Dedicated screen for file changes (swipe from dashboard).

```
┌─────────────────────────────┐
│ Activity             ● Live │
├─────────────────────────────┤
│                             │
│ 12:34 ui-refactor           │
│   M Button.tsx          ⟩   │
│   M Modal.tsx           ⟩   │
│                             │
│ 12:33 api-work              │
│   M auth.ts             ⟩   │
│                             │
│ 12:32 ui-refactor           │
│   A Dialog.tsx          ⟩   │
│                             │
│ 12:30 styling               │
│   M theme.css           ⟩   │
│                             │
├─────────────────────────────┤
│ [All] [frontend] [backend]  │
└─────────────────────────────┘
```

**Elements:**
- Chronological stream
- Grouped by timestamp + session
- Filter tabs at bottom
- Tap file to open/view

**Gestures:**
- Swipe left → Back to dashboard
- Pull down → Refresh
- Tap filter → Filter by group

---

### 4. Mobile Diff View

Simplified diff viewer.

```
┌─────────────────────────────┐
│ ← Button.tsx         +42    │
├─────────────────────────────┤
│                             │
│ @@ -23,7 +23,12 @@          │
│  export function Button...  │
│    const theme = useTheme() │
│ -  return <button ...       │
│ +  const ripple = useRip... │
│ +  return (                 │
│ +    <button                │
│ +      className={cn(...    │
│ +      onMouseDown={rip...  │
│                             │
│                             │
├─────────────────────────────┤
│ [← Prev]  [Stage]  [Next →] │
└─────────────────────────────┘
```

**Elements:**
- Horizontal scroll for long lines (or wrap)
- Swipe between files
- Stage action prominent

**Gestures:**
- Swipe left/right → Prev/next file
- Double-tap → Toggle line wrap
- Pinch → Zoom text size

---

### 5. Mobile Servers

Server overview for multi-server use.

```
┌─────────────────────────────┐
│ Servers              3 conn │
├─────────────────────────────┤
│                             │
│ ● local                     │
│   4 sessions · 12 files  ⟩  │
│                             │
│ ● hetzner          45ms     │
│   2 sessions · 5 files   ⟩  │
│                             │
│ ○ nixos-vm                  │
│   offline                ⟩  │
│                             │
│                             │
│                             │
├─────────────────────────────┤
│ [+ Add]        [↻ Refresh]  │
└─────────────────────────────┘
```

**Gestures:**
- Tap server → Server sessions
- Swipe left on server → Disconnect/reconnect
- Long press → Server settings

---

### 6. Mobile Quick Actions

Swipe-left menu on session row.

```
┌─────────────────────────────┐
│ nous            ● 4 active  │
├─────────────────────────────┤
│                             │
│ ▸ frontend (2)              │
│ ┌─────────────────────────┐ │
│ │ ● ui-refactor    [Focus]│◀── swiped
│ │              [Diff][Kill]│ │
│ └─────────────────────────┘ │
│   ○ styling         12m ⟩   │
│                             │
│ ▸ backend (1)               │
│   ● api-work         1m ⟩   │
│                             │
├─────────────────────────────┤
│ [+]  [⌕]  [≡]  [↻]  [?]    │
└─────────────────────────────┘
```

Quick actions without entering detail view.

---

### 7. Mobile New Session

Simplified form for mobile.

```
┌─────────────────────────────┐
│ New Session                 │
├─────────────────────────────┤
│                             │
│ Name                        │
│ ┌─────────────────────────┐ │
│ │ fix-auth                │ │
│ └─────────────────────────┘ │
│                             │
│ Directory                   │
│ ┌─────────────────────────┐ │
│ │ ~/projects/api       ▾  │ │
│ └─────────────────────────┘ │
│                             │
│ ● local  ○ hetzner         │
│                             │
│                             │
├─────────────────────────────┤
│ [Cancel]          [Create]  │
└─────────────────────────────┘
```

**Elements:**
- Minimal fields
- Dropdown for recent directories
- Server selection (no group/layout on mobile)

---

## Navigation Model

### Swipe Navigation

```
                    [Activity]
                         ↑
                    swipe up

[Servers] ←swipe→ [Dashboard] ←swipe→ [Search]

                   swipe down
                         ↓
                    [Groups]
```

### Screen Hierarchy

```
Dashboard
├── Session Detail
│   ├── Diff View
│   └── Output View (stretch)
├── Activity Stream
├── Servers
│   └── Server Sessions
├── Groups
│   └── Group Detail
├── Search
│   └── Results → Session/File
└── New Session
```

---

## Keyboard Shortcuts (Mobile)

Minimize keystrokes. Most actions via touch.

| Key | Action |
|-----|--------|
| `j/k` | Navigate up/down |
| `Enter` | Select / Focus |
| `Esc` | Back |
| `n` | New session |
| `/` | Search |
| `r` | Refresh |
| `?` | Help |

Single letters only. No chords (Ctrl+X) on mobile keyboards.

---

## Termius-Specific Considerations

### Termius Features to Leverage

- **Snippets**: Pre-configure `nous` launch command
- **Quick Connect**: Save SSH connections to servers
- **Port Forwarding**: For agent communication
- **Keyboard Toolbar**: Custom keys above keyboard

### Recommended Termius Setup

```
Snippet: nous
Command: nous --mobile

Snippet: nous-new
Command: nous new --quick

Snippet: nous-activity
Command: nous activity
```

### Terminal Settings

- Font: Monospace, 12-14pt for readability
- Theme: Match nous deep blue
- Keyboard toolbar: Add `Esc`, `Tab`, `/`, `?`

---

## Responsive Behavior

Nous should detect terminal size and adapt:

```typescript
interface LayoutMode {
  mode: 'desktop' | 'tablet' | 'mobile';
  cols: number;
  rows: number;
}

function detectLayout(): LayoutMode {
  const { columns, rows } = process.stdout;

  if (columns < 50 || rows < 20) {
    return { mode: 'mobile', cols: columns, rows };
  } else if (columns < 100) {
    return { mode: 'tablet', cols: columns, rows };
  }
  return { mode: 'desktop', cols: columns, rows };
}
```

### Breakpoints

| Mode | Columns | Rows | Layout |
|------|---------|------|--------|
| Mobile | < 50 | < 20 | Single column, compressed |
| Tablet | 50-99 | 20-30 | Single column, expanded |
| Desktop | 100+ | 30+ | Two column, full |

---

## Mobile-First Features

Features that are especially valuable on mobile:

### 1. Quick Focus

One tap to jump to a session's tmux pane. Most common action.

### 2. Activity Notifications

Badge or indicator when sessions have new changes:
```
● ui-refactor      3m  (3)  ← 3 new files changed
```

### 3. Session Status at Glance

See immediately if Claude is:
- `●` Active (working)
- `◐` Waiting (for input)
- `○` Idle (paused)

### 4. Offline Mode

Cache session list locally. Show stale data with indicator:
```
┌─────────────────────────────┐
│ nous        ⚠ offline 2m   │
```

### 5. Push Notifications (Future App)

If nous becomes an app:
- "ui-refactor completed task"
- "api-work waiting for input"
- "Deploy to hetzner finished"

---

## Future: Native App Considerations

If nous becomes a native mobile app (not just TUI):

### Advantages

- Push notifications
- Background refresh
- Native gestures
- Better keyboard handling
- Offline support
- Widgets (iOS/Android)

### Architecture

```
┌──────────────┐     ┌──────────────┐
│  Nous App    │────▶│  Nous API    │
│  (iOS/And)   │◀────│  (on server) │
└──────────────┘     └──────────────┘
                            │
                     ┌──────┴──────┐
                     │   Agents    │
                     │ (each host) │
                     └─────────────┘
```

The coordinator becomes an API server, app becomes a client.

### MVP App Features

1. Session list with status
2. Activity stream
3. Quick focus (SSH handoff to Termius/Blink)
4. Push notifications
5. Basic session management

### Stretch App Features

- Inline diff viewing
- Voice input for prompts
- Watch for file changes (Apple Watch complication?)
- Shortcuts/Widgets integration

---

## Open Questions

- [ ] How do we detect mobile vs desktop? Terminal size? Flag?
- [ ] Should `--mobile` flag force mobile layout?
- [ ] How do we handle SSH disconnection gracefully on mobile?
- [ ] Is swipe navigation feasible in terminal, or touch-only in app?
- [ ] What's the MVP mobile feature set vs desktop parity?

---

## Testing on Mobile

### Setup

1. Install Termius on phone
2. SSH to your machine running nous
3. Test with various terminal sizes

### Test Scenarios

- [ ] Portrait orientation
- [ ] Landscape orientation
- [ ] Keyboard open vs closed
- [ ] Rapid session switching
- [ ] File change stream
- [ ] Connection drop/reconnect

### Devices to Test

- [ ] iPhone (Termius)
- [ ] iPad (Termius, Blink)
- [ ] Android phone (Termius, JuiceSSH)
- [ ] Android tablet
