# Nous: Technical Spikes

Document results of technical experiments here. Fill in during Iteration 10.

---

## Spike 1: Tmux Session Discovery

**Goal**: Can we reliably find Claude processes and their tmux panes?

### Command Tested

```bash
tmux list-panes -a -F '#{pane_id}:#{pane_pid}:#{pane_current_command}:#{pane_current_path}'
```

### Results

**macOS**:
```
_output here_
```

**Linux (NixOS)**:
```
_output here_
```

### Findings

- [ ] Can identify claude processes
- [ ] Can get working directory
- [ ] Can get pane ID for focusing
- [ ] Works on both platforms

### Adjusted Assumptions

_What we learned that changes our approach_

---

## Spike 2: File Watching with Bun

**Goal**: Does Bun's file watcher perform well enough?

### Code Tested

```typescript
import { watch } from "fs";

const watcher = watch("./", { recursive: true }, (event, filename) => {
  console.log(new Date().toISOString(), event, filename);
});

// Let it run for a few minutes while making changes
```

### Results

**Performance**:
- Events per second handled: ___
- Memory usage: ___
- CPU usage: ___

**Behavior**:
- [ ] Recursive watching works
- [ ] Debounce needed? ___ms
- [ ] Events for all file types
- [ ] Handles rapid changes

### Ignore Patterns Needed

```
.git/
node_modules/
*.log
_other patterns_
```

### Adjusted Assumptions

_What we learned that changes our approach_

---

## Spike 3: OSC 8 Hyperlinks

**Goal**: Do clickable terminal links work?

### Code Tested

```typescript
const link = (url: string, text: string) =>
  `\x1b]8;;${url}\x1b\\${text}\x1b]8;;\x1b\\`;

console.log(link("file:///path/to/file.ts", "file.ts"));
console.log(link("file:///path/to/file.ts:42", "file.ts:42"));
```

### Results

| Terminal | Works? | Notes |
|----------|--------|-------|
| iTerm2 | | |
| Kitty | | |
| Alacritty | | |
| Terminal.app | | |
| Ghostty | | |

### File URL Format

What format works for opening files?

- [ ] `file:///absolute/path`
- [ ] `file:///absolute/path:line`
- [ ] `file:///absolute/path:line:col`
- [ ] Custom scheme needed?

### Editor Integration

How to open in neovim at specific line?

```bash
_command that works_
```

### Adjusted Assumptions

_What we learned that changes our approach_

---

## Spike 4: SSH Tunnel Stability

**Goal**: Can we maintain a stable tunnel for agent communication?

### Test Setup

```bash
# Terminal 1: Start listener on remote
ssh claude@77.42.27.244 "nc -l 9999"

# Terminal 2: Forward and connect
ssh -L 9999:localhost:9999 claude@77.42.27.244
nc localhost 9999
```

### Results

**Connection Stability**:
- [ ] Stays connected over _____ minutes
- [ ] Reconnects automatically: yes/no
- [ ] Latency: ___ms average

**Network Conditions Tested**:
| Condition | Behavior |
|-----------|----------|
| Stable connection | |
| Brief disconnect | |
| High latency | |
| Packet loss | |

### Alternative: WebSocket

If SSH tunnel doesn't work well, test WebSocket:

```typescript
// Agent side
Bun.serve({
  port: 9999,
  fetch(req, server) {
    server.upgrade(req);
  },
  websocket: {
    message(ws, message) {
      console.log("received:", message);
    },
  },
});
```

### Adjusted Assumptions

_What we learned that changes our approach_

---

## Spike 5: TUI Framework

**Goal**: Which framework feels right?

### Ink Test

```typescript
import { render, Text, Box } from "ink";
import { useState } from "react";

const App = () => {
  const [selected, setSelected] = useState(0);
  // ... handle j/k
  return (
    <Box flexDirection="column">
      <Text>Session 1</Text>
      <Text>Session 2</Text>
    </Box>
  );
};

render(<App />);
```

**Pros**:
-

**Cons**:
-

### Blessed Test

```typescript
import blessed from "blessed";

const screen = blessed.screen({ smartCSR: true });
const list = blessed.list({
  items: ["Session 1", "Session 2"],
  keys: true,
  vi: true,
});
screen.append(list);
screen.render();
```

**Pros**:
-

**Cons**:
-

### Custom ANSI Test

```typescript
const clear = "\x1b[2J\x1b[H";
const moveTo = (row: number, col: number) => `\x1b[${row};${col}H`;
const bold = (text: string) => `\x1b[1m${text}\x1b[0m`;

process.stdout.write(clear);
process.stdout.write(moveTo(1, 1) + bold("nous"));
process.stdout.write(moveTo(3, 1) + "Session 1");
```

**Pros**:
-

**Cons**:
-

### Decision

Framework chosen: _______________

Rationale:

---

## Spike 6: Process Association

**Goal**: Can we associate file changes with specific Claude processes?

### Approach 1: Directory Ownership

Each session "owns" its working directory.

```typescript
const sessions = new Map<string, Session>();
// session.workingDir = "/home/claude/projects/app"

function attributeChange(filePath: string): Session | null {
  for (const [id, session] of sessions) {
    if (filePath.startsWith(session.workingDir)) {
      return session;
    }
  }
  return null;
}
```

**Problem**: What if two sessions share a directory?

### Approach 2: Process Tracing

Use `lsof` or similar to see which process has the file open.

```bash
lsof /path/to/file.ts
```

**Results**:
- [ ] Works on macOS
- [ ] Works on Linux
- [ ] Fast enough for real-time
- [ ] Can identify claude subprocess

### Approach 3: Git-Based

Don't track real-time, just poll git status.

```bash
git status --porcelain
```

**Results**:
- [ ] Shows all changes
- [ ] Can't attribute to session
- [ ] Fast enough: ___ms

### Decision

Approach chosen: _______________

Rationale:

---

## Summary

| Spike | Status | Key Finding |
|-------|--------|-------------|
| Tmux Discovery | | |
| File Watching | | |
| OSC 8 Links | | |
| SSH Tunnel | | |
| TUI Framework | | |
| Process Association | | |

## Blockers Discovered

_Anything that fundamentally changes our approach_

1.
2.

## Adjusted Architecture

_Any changes to PLAN.md based on spike results_
