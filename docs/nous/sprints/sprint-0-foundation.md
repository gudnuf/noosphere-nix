# Sprint 0: Foundation

**Duration:** ~2 weeks
**Status:** Not started

## Goal

Set up the project structure and prove the core technical concepts work together. By the end, we have a working app that can list tmux sessions and switch between them.

## What We'll Achieve

- Tauri project initialized with React frontend
- Rust backend can communicate with tmux
- Basic window with session list
- Keyboard navigation works (j/k, Enter)
- Can focus a session (switches tmux pane)

## Key Questions to Answer

- Does Tauri + React feel right for this project?
- Can we reliably get session info from tmux via Rust?
- What's the IPC pattern between frontend and backend?
- How do we handle the dev workflow (hot reload, etc.)?

## Milestone

**"I can see my Claude sessions in a GUI window and switch between them with the keyboard."**

---

# Implementation Plan

## Phase 1: Project Setup (Day 1-2)

### 1.1 Create Tauri + React Project

```bash
# Location: ~/nous/.trees/gui (new directory, parallel to gui-attempt)
cd ~/nous/.trees
npm create tauri-app@latest gui -- --template react-ts
cd gui
```

**Directory structure we want:**
```
gui/
├── src/                    # React frontend
│   ├── components/
│   │   └── SessionList.tsx
│   ├── hooks/
│   │   └── useSessions.ts
│   ├── lib/
│   │   └── tauri.ts        # Tauri IPC wrapper
│   ├── App.tsx
│   ├── main.tsx
│   └── index.css
├── src-tauri/              # Rust backend
│   ├── src/
│   │   ├── main.rs
│   │   ├── commands/
│   │   │   └── sessions.rs  # tmux integration
│   │   └── tmux.rs          # tmux command wrapper
│   ├── Cargo.toml
│   └── tauri.conf.json
├── package.json
└── vite.config.ts
```

### 1.2 Configure Tailwind CSS

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

**tailwind.config.js:**
```js
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        bg: {
          primary: '#0d1117',
          secondary: '#161b22',
          elevated: '#21262d',
        },
        border: '#30363d',
        active: '#58a6ff',
        success: '#3fb950',
        idle: '#6e7681',
      },
    },
  },
}
```

### 1.3 Nix Dev Environment

**flake.nix:**
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, rust-overlay, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Rust
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" "rust-analyzer" ];
              })

              # Node
              nodejs_22
              nodePackages.npm

              # Tauri deps (Linux)
              pkg-config
              openssl
              webkitgtk_4_1
              libsoup_3
              glib-networking

              # Tools
              tmux
            ];
          };
        }
      );
    };
}
```

---

## Phase 2: Rust Backend - tmux Integration (Day 3-5)

### 2.1 Cargo Dependencies

**src-tauri/Cargo.toml additions:**
```toml
[dependencies]
tauri = { version = "2", features = ["devtools"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["process", "rt-multi-thread"] }
```

### 2.2 Session Data Model

**src-tauri/src/tmux.rs:**
```rust
use serde::{Deserialize, Serialize};
use std::process::Command;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    pub id: String,
    pub pane_id: String,
    pub pane_target: String,
    pub working_dir: String,
    pub command: String,
    pub is_active: bool,
    pub title: Option<String>,
}
```

### 2.3 tmux Commands to Implement

Port these from the existing TypeScript:

| Function | tmux Command | Purpose |
|----------|--------------|---------|
| `list_sessions()` | `tmux list-panes -s -t nous -F "..."` | Get all Claude sessions |
| `focus_pane(id)` | `tmux select-pane -t {id}` | Switch to session |
| `create_session(dir)` | `tmux split-window -h -c {dir} claude` | New session |
| `kill_pane(id)` | `tmux kill-pane -t {id}` | End session |

### 2.4 Tauri Commands

**src-tauri/src/commands/sessions.rs:**
```rust
use crate::tmux::{self, Session};
use tauri::command;

#[command]
pub async fn list_sessions() -> Result<Vec<Session>, String> {
    tmux::list_sessions().map_err(|e| e.to_string())
}

#[command]
pub async fn focus_session(pane_id: String) -> Result<(), String> {
    tmux::focus_pane(&pane_id).map_err(|e| e.to_string())
}

#[command]
pub async fn create_session(working_dir: Option<String>) -> Result<Session, String> {
    tmux::create_session(working_dir.as_deref())
        .map_err(|e| e.to_string())
}

#[command]
pub async fn kill_session(pane_id: String) -> Result<(), String> {
    tmux::kill_pane(&pane_id).map_err(|e| e.to_string())
}
```

### 2.5 Register Commands

**src-tauri/src/main.rs:**
```rust
mod commands;
mod tmux;

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            commands::sessions::list_sessions,
            commands::sessions::focus_session,
            commands::sessions::create_session,
            commands::sessions::kill_session,
        ])
        .run(tauri::generate_context!())
        .expect("error running tauri app");
}
```

---

## Phase 3: React Frontend - Basic UI (Day 6-8)

### 3.1 Tauri IPC Wrapper

**src/lib/tauri.ts:**
```typescript
import { invoke } from '@tauri-apps/api/core';

export interface Session {
  id: string;
  pane_id: string;
  pane_target: string;
  working_dir: string;
  command: string;
  is_active: boolean;
  title?: string;
}

export const api = {
  listSessions: () => invoke<Session[]>('list_sessions'),
  focusSession: (paneId: string) => invoke('focus_session', { paneId }),
  createSession: (workingDir?: string) => invoke<Session>('create_session', { workingDir }),
  killSession: (paneId: string) => invoke('kill_session', { paneId }),
};
```

### 3.2 Sessions Hook

**src/hooks/useSessions.ts:**
```typescript
import { useState, useEffect, useCallback } from 'react';
import { api, Session } from '../lib/tauri';

export function useSessions() {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    try {
      const data = await api.listSessions();
      setSessions(data);
      setError(null);
    } catch (e) {
      setError(e as string);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    refresh();
    const interval = setInterval(refresh, 2000);
    return () => clearInterval(interval);
  }, [refresh]);

  return { sessions, loading, error, refresh };
}
```

### 3.3 Session List Component

**src/components/SessionList.tsx:**
```tsx
interface Props {
  sessions: Session[];
  selectedIndex: number;
  onSelect: (index: number) => void;
  onFocus: (session: Session) => void;
}

export function SessionList({ sessions, selectedIndex, onSelect, onFocus }: Props) {
  return (
    <div className="flex flex-col gap-1 p-2">
      {sessions.map((session, index) => (
        <div
          key={session.id}
          className={`
            flex items-center gap-3 px-3 py-2 rounded-md cursor-pointer
            ${index === selectedIndex ? 'bg-bg-elevated' : 'hover:bg-bg-secondary'}
          `}
          onClick={() => onFocus(session)}
        >
          <span className={session.is_active ? 'text-active' : 'text-idle'}>
            {session.is_active ? '●' : '○'}
          </span>
          <span className="text-sm text-gray-300 truncate">
            {shortenPath(session.working_dir)}
          </span>
        </div>
      ))}
    </div>
  );
}
```

### 3.4 Keyboard Navigation

**src/hooks/useKeyboard.ts:**
```typescript
import { useEffect } from 'react';

type KeyMap = Record<string, () => void>;

export function useKeyboard(keyMap: KeyMap) {
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      const key = e.key.toLowerCase();
      if (keyMap[key]) {
        e.preventDefault();
        keyMap[key]();
      }
    };

    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [keyMap]);
}
```

### 3.5 Main App

**src/App.tsx:**
```tsx
function App() {
  const { sessions, refresh } = useSessions();
  const [selectedIndex, setSelectedIndex] = useState(0);

  useKeyboard({
    'j': () => setSelectedIndex(i => Math.min(i + 1, sessions.length - 1)),
    'k': () => setSelectedIndex(i => Math.max(i - 1, 0)),
    'enter': () => {
      if (sessions[selectedIndex]) {
        api.focusSession(sessions[selectedIndex].pane_id);
      }
    },
    'n': async () => {
      await api.createSession();
      refresh();
    },
    'r': refresh,
  });

  return (
    <div className="min-h-screen bg-bg-primary text-gray-100">
      <header className="border-b border-border px-4 py-2">
        <h1 className="text-sm font-medium">nous</h1>
      </header>
      <SessionList
        sessions={sessions}
        selectedIndex={selectedIndex}
        onSelect={setSelectedIndex}
        onFocus={(s) => api.focusSession(s.pane_id)}
      />
      <footer className="fixed bottom-0 w-full border-t border-border px-4 py-2 text-xs text-gray-500">
        j/k navigate · Enter focus · n new · r refresh
      </footer>
    </div>
  );
}
```

---

## Phase 4: Window Configuration (Day 9)

### 4.1 Tauri Window Settings

**src-tauri/tauri.conf.json:**
```json
{
  "app": {
    "windows": [
      {
        "title": "nous",
        "width": 400,
        "height": 600,
        "resizable": true,
        "decorations": true,
        "transparent": false,
        "alwaysOnTop": false
      }
    ]
  },
  "build": {
    "devUrl": "http://localhost:5173",
    "frontendDist": "../dist"
  }
}
```

### 4.2 Window Styling

- Dark title bar (match app theme)
- Sensible default size (400x600 - sidebar-like)
- Remember position on restart (stretch goal)

---

## Phase 5: Testing & Polish (Day 10-12)

### 5.1 Manual Test Cases

| Test | Expected |
|------|----------|
| Launch app (no tmux) | Shows error/empty state |
| Launch app (tmux, no sessions) | Shows empty list, can press `n` |
| Launch app (tmux, 3 sessions) | Shows 3 sessions |
| Press `j`/`k` | Selection moves |
| Press `Enter` | tmux switches pane |
| Press `n` | New session created, list updates |
| Press `r` | List refreshes |
| Resize window | Layout adjusts |

### 5.2 Edge Cases to Handle

- [ ] tmux not running
- [ ] "nous" session doesn't exist
- [ ] Session killed externally (refresh catches it)
- [ ] Very long directory paths (truncate)
- [ ] Many sessions (scrolling)

### 5.3 Polish Items

- [ ] Loading skeleton on startup
- [ ] Error state UI
- [ ] Smooth selection transitions
- [ ] Focus ring for accessibility

---

## Phase 6: Integration (Day 13-14)

### 6.1 Nix Build

Add to flake.nix:
```nix
packages.default = pkgs.callPackage ./package.nix { };
```

### 6.2 Dev Workflow

Document in README:
```bash
# Enter dev environment
nix develop

# Run in dev mode (hot reload)
npm run tauri dev

# Build release
npm run tauri build
```

### 6.3 Verify Milestone

Final checklist:
- [ ] App launches from `nix run`
- [ ] Shows real tmux sessions
- [ ] j/k navigation works
- [ ] Enter focuses session
- [ ] n creates new session
- [ ] No crashes for 10 minutes of use

---

## Spikes Needed

- [ ] Tauri hello world with React
- [ ] Rust tmux-interface crate exploration
- [ ] IPC command pattern (Rust ↔ JS)

## Notes

_Fill in during sprint_

---

## Retrospective

_Fill in after sprint_

**What worked:**

**What didn't:**

**Decisions made:**
