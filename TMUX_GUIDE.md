# Tmux Navigation & Pane/Window Management Guide

## Your Tmux Configuration

Based on your nix-config at `.config/nix-config/home/modules/dev-tools.nix:56-92`, you have:

- **Prefix key**: `Ctrl+b` (default)
- **Vi mode**: Enabled (for copy mode)
- **Mouse support**: Enabled
- **Custom split bindings**: `|` (horizontal) and `-` (vertical)
- **Vim-style navigation**: `h/j/k/l` for moving between panes
- **Window/pane indexing**: Starts at 1 (not 0)

---

## Quick Reference Card

**Prefix Key = `Ctrl+b`** (press this before any command below)

| Action | Keys |
|--------|------|
| **Split vertical** | `Prefix` then `\|` |
| **Split horizontal** | `Prefix` then `-` |
| **Navigate panes** | `Prefix` then `h/j/k/l` |
| **Close pane** | `Prefix` then `x` or just `exit` |
| **New window** | `Prefix` then `c` |
| **Next window** | `Prefix` then `n` |
| **Previous window** | `Prefix` then `p` |
| **Close window** | `Prefix` then `&` or close all panes |
| **Detach session** | `Prefix` then `d` |

---

## Exercises to Get Familiar with Tmux

### Exercise 1: Start and Exit Tmux
**Goal:** Get comfortable launching and leaving tmux

1. Start tmux: `tmux`
2. Notice the status bar at the bottom showing `[0] 0:zsh*`
3. Detach (leave tmux running in background): `Prefix d` (Ctrl+b, then d)
4. List sessions: `tmux ls`
5. Re-attach to session: `tmux attach` or `tmux a`
6. Kill session completely: `exit` or `Prefix` then type `:kill-session` and Enter

### Exercise 2: Create and Navigate Panes
**Goal:** Master splitting and moving between panes

1. Start tmux: `tmux`
2. Split vertically (left/right): `Prefix |`
3. You now have 2 panes side-by-side
4. Move to right pane: `Prefix l`
5. Move back to left pane: `Prefix h`
6. From left pane, split horizontally (top/bottom): `Prefix -`
7. You now have 3 panes
8. Navigate using vim keys:
   - `Prefix j` - move down
   - `Prefix k` - move up
   - `Prefix h` - move left
   - `Prefix l` - move right
9. Practice moving between all 3 panes using these keys

### Exercise 3: Close Panes
**Goal:** Learn different ways to close panes

1. Create 4 panes (use `|` and `-` to split)
2. Navigate to any pane
3. Close it by typing: `exit` (or `Ctrl+d`)
4. Notice the pane disappears and the remaining ones resize
5. Navigate to another pane
6. Close using tmux command: `Prefix x`, then press `y` to confirm
7. Close remaining panes until back to one pane

### Exercise 4: Create and Navigate Windows
**Goal:** Work with multiple windows (tabs)

1. Start with a fresh tmux session
2. Create new window: `Prefix c`
3. Notice the status bar now shows `[1] 0:zsh- 1:zsh*`
   - Window 0 exists (previous)
   - Window 1 is active (current) - shown by `*`
4. Switch to previous window: `Prefix p`
5. Switch to next window: `Prefix n`
6. Create a third window: `Prefix c`
7. Jump directly to window 0: `Prefix 0`
8. Jump directly to window 1: `Prefix 1`
9. Jump directly to window 2: `Prefix 2`

### Exercise 5: Rename Windows for Organization
**Goal:** Give windows meaningful names

1. Create 3 windows
2. In first window, rename it: `Prefix ,`
3. Type `editor` and press Enter
4. Switch to second window: `Prefix n`
5. Rename it to `server`: `Prefix ,` then type `server`
6. Switch to third window and rename to `logs`
7. Notice the status bar shows: `[0:editor 1:server 2:logs*]`
8. Navigate using names instead of numbers

### Exercise 6: Close Windows
**Goal:** Learn to close windows safely

1. Create 3 windows with different names
2. Navigate to window 1
3. Close it: `Prefix &`, then press `y` to confirm
4. Notice window disappears from status bar
5. Alternatively, just type `exit` in a window with only one pane
6. If a window has multiple panes, you must close all panes first

### Exercise 7: Complex Layout Navigation
**Goal:** Practice navigating a realistic multi-pane, multi-window setup

1. Create this layout:
   - Window 0 "code": Split into 3 panes (1 large left, 2 stacked right)
     - `Prefix |` (creates 2 vertical panes)
     - `Prefix l` (move to right pane)
     - `Prefix -` (split right pane horizontally)
   - Window 1 "server": Single pane
     - `Prefix c` (create new window)
     - `Prefix ,` then type `server`
   - Window 2 "logs": Split horizontally into 2 panes
     - `Prefix c` (create new window)
     - `Prefix ,` then type `logs`
     - `Prefix -` (split horizontally)
2. Practice navigating:
   - Between windows: `Prefix n` / `Prefix p` / `Prefix 0-2`
   - Between panes in window 0: `Prefix h/j/k/l`
   - Between panes in window 2: `Prefix j/k`
3. Close everything when done

### Exercise 8: Using Mouse Support
**Goal:** Learn that you have mouse support enabled

1. Create a few panes with splits
2. Click on a pane with your mouse - it becomes active
3. Drag the pane border with mouse to resize
4. Create multiple windows
5. Click on window names in status bar to switch
6. Right-click on a pane to see a menu (if supported by terminal)
7. Scroll in pane with mouse wheel

### Exercise 9: Detach and Reattach
**Goal:** Learn persistent sessions

1. Create a multi-window, multi-pane setup
2. Detach from session: `Prefix d`
3. Do other terminal work
4. List tmux sessions: `tmux ls`
5. Re-attach: `tmux attach`
6. Your layout is exactly as you left it!
7. Create a named session for easy re-attachment:
   - Exit tmux
   - Start named session: `tmux new -s myproject`
   - Detach: `Prefix d`
   - Re-attach by name: `tmux attach -t myproject`

### Exercise 10: Master the Workflow
**Goal:** Put it all together in a realistic scenario

1. Start a named session: `tmux new -s dev`
2. Rename first window to `editor`: `Prefix ,`
3. Split for editor + terminal:
   - `Prefix -` (horizontal split)
4. Create new window for server: `Prefix c`, rename to `server`
5. Create new window for logs: `Prefix c`, rename to `logs`
6. Split logs window: `Prefix -`
7. Navigate between windows: `Prefix 1`, `Prefix 2`, `Prefix 3`
8. Navigate between panes in editor window: `Prefix j/k`
9. Detach: `Prefix d`
10. Re-attach: `tmux attach -t dev`
11. Kill session when done: `Prefix :kill-session`

---

## Cheatsheet: Navigation & Pane/Window Management

### Starting & Stopping Tmux

| Command | Action |
|---------|--------|
| `tmux` | Start new session |
| `tmux new -s name` | Start new session with name |
| `tmux ls` | List all sessions |
| `tmux attach` | Attach to last session |
| `tmux attach -t name` | Attach to named session |
| `tmux kill-session -t name` | Kill specific session |

### Prefix Key

**All commands below require pressing `Prefix` first**
- Your prefix: `Ctrl+b`
- Example: "Prefix c" means: Press `Ctrl+b`, release, then press `c`

### Pane Management

| Command | Action |
|---------|--------|
| `Prefix \|` | Split pane vertically (left/right) - **YOUR CONFIG** |
| `Prefix -` | Split pane horizontally (top/bottom) - **YOUR CONFIG** |
| `Prefix %` | Split pane vertically (default binding) |
| `Prefix "` | Split pane horizontally (default binding) |
| `Prefix h` | Move to left pane - **YOUR CONFIG** |
| `Prefix j` | Move to pane below - **YOUR CONFIG** |
| `Prefix k` | Move to pane above - **YOUR CONFIG** |
| `Prefix l` | Move to right pane - **YOUR CONFIG** |
| `Prefix ←↑↓→` | Move to pane (arrow keys, default) |
| `Prefix o` | Cycle through panes |
| `Prefix x` | Close current pane (confirm with 'y') |
| `exit` or `Ctrl+d` | Close current pane (no confirmation) |
| `Prefix z` | Toggle pane zoom (fullscreen) |
| `Prefix q` | Show pane numbers (press number to jump) |
| `Prefix {` | Swap pane with previous |
| `Prefix }` | Swap pane with next |
| `Prefix Space` | Cycle through pane layouts |

### Pane Resizing

| Command | Action |
|---------|--------|
| `Prefix H` | Resize pane left - **YOUR CONFIG** |
| `Prefix J` | Resize pane down - **YOUR CONFIG** |
| `Prefix K` | Resize pane up - **YOUR CONFIG** |
| `Prefix L` | Resize pane right - **YOUR CONFIG** |
| `Prefix Ctrl+←↑↓→` | Resize pane (arrow keys, default) |

Note: Your config uses `-r` flag, so you can hold Prefix and press H/J/K/L repeatedly

### Window Management

| Command | Action |
|---------|--------|
| `Prefix c` | Create new window |
| `Prefix ,` | Rename current window |
| `Prefix n` | Move to next window |
| `Prefix p` | Move to previous window |
| `Prefix 0-9` | Jump to window number (yours start at 1) |
| `Prefix w` | List all windows (choose with arrows) |
| `Prefix &` | Close current window (confirm with 'y') |
| `Prefix f` | Find window by name |
| `Prefix l` | Toggle between last used windows |

### Session Management

| Command | Action |
|---------|--------|
| `Prefix d` | Detach from session |
| `Prefix $` | Rename current session |
| `Prefix s` | List all sessions (choose with arrows) |
| `Prefix (` | Switch to previous session |
| `Prefix )` | Switch to next session |

### Mouse Actions (You Have Mouse Enabled!)

| Action | Effect |
|--------|--------|
| Click on pane | Switch to that pane |
| Click on window in status bar | Switch to that window |
| Drag pane border | Resize panes |
| Scroll in pane | Scroll through output |
| Right-click pane | Context menu (terminal dependent) |

### Help & Information

| Command | Action |
|---------|--------|
| `Prefix ?` | List all key bindings |
| `Prefix t` | Show clock |
| `Prefix :` | Enter command mode |

### Command Mode (Prefix :)

After pressing `Prefix :`, you can type these commands:

| Command | Action |
|---------|--------|
| `kill-session` | Kill current session |
| `kill-pane` | Kill current pane |
| `kill-window` | Kill current window |
| `source-file ~/.config/tmux/tmux.conf` | Reload config |
| `setw synchronize-panes` | Toggle typing in all panes at once |

Note: Your config has `Prefix r` mapped to reload config automatically

### Your Custom Keybindings Summary

Your nix-config includes these custom bindings:

```
Split Panes:
  Prefix | → split-window -h (vertical split, new pane on right)
  Prefix - → split-window -v (horizontal split, new pane below)

Navigate Panes (Vim-style):
  Prefix h → select-pane -L (left)
  Prefix j → select-pane -D (down)
  Prefix k → select-pane -U (up)
  Prefix l → select-pane -R (right)

Resize Panes (Vim-style, repeatable):
  Prefix H → resize-pane -L 5 (left 5 units)
  Prefix J → resize-pane -D 5 (down 5 units)
  Prefix K → resize-pane -U 5 (up 5 units)
  Prefix L → resize-pane -R 5 (right 5 units)

Config:
  Prefix r → reload tmux config
```

---

## Common Workflows

### Basic Development Setup
```
1. tmux new -s project
2. Prefix , → name window "editor"
3. Prefix - → split for terminal below
4. Prefix c → create window
5. Prefix , → name window "server"
6. Work, then Prefix d to detach
7. tmux attach -t project when you return
```

### Three-Column Layout
```
1. Start with one pane
2. Prefix | → create right pane
3. Prefix | → create another right pane
4. Prefix h → go to middle pane
5. Adjust sizes: Prefix L L L (resize right)
6. Or just drag borders with mouse
```

### Quick Split and Close
```
# Split and work
Prefix | → vertical split
Prefix h/l → navigate
exit → close current pane

# Or use zoom
Prefix z → fullscreen current pane
Prefix z → unzoom back to splits
```

### Window Tabs for Different Tasks
```
# Create organized windows
Window 0: code (editor + terminal split)
Window 1: server (running dev server)
Window 2: logs (tailing log files)
Window 3: git (lazygit or git commands)

# Navigate with Prefix 0-3
# Or Prefix n/p to cycle through
```

---

## Tips & Tricks

### Muscle Memory Keys
- **Most used**: `Prefix |`, `Prefix -`, `Prefix h/j/k/l`
- **Window switching**: `Prefix n/p` or `Prefix 1/2/3`
- **Quick exit**: Just type `exit` instead of `Prefix x`
- **Zoom pane**: `Prefix z` (your new best friend)

### Understanding Splits
- `|` creates **vertical** split = left/right panes (vertical divider)
- `-` creates **horizontal** split = top/bottom panes (horizontal divider)
- This matches the visual appearance of the symbols!

### Mouse vs Keyboard
- **Mouse**: Great for quick pane switching and resizing
- **Keyboard**: Faster once you learn the keys
- **Both**: Use mouse when learning, transition to keyboard for speed

### Session Organization
```
tmux new -s work      # Work projects
tmux new -s personal  # Personal projects
tmux new -s sandbox   # Experimentation

# List all: tmux ls
# Attach: tmux attach -t work
# Switch: Prefix s (then arrow keys)
```

### When Things Go Wrong
- **Lost in panes?**: `Prefix q` shows numbers
- **Weird layout?**: `Prefix Space` cycles layouts
- **Pane too small?**: `Prefix z` to zoom it
- **Accidentally closed pane?**: Can't undo, be careful with `exit`
- **Tmux frozen?**: You might be in copy mode, press `q` to exit

### Persistent Sessions
- Tmux sessions survive:
  - Terminal window closing
  - SSH disconnections
  - Accidental terminal quits
- They DON'T survive system reboots
- Always name important sessions: `tmux new -s important`

### Copy Mode (Vi-style)
You have vi mode enabled, so:
1. `Prefix [` → enter copy mode
2. Use `h/j/k/l` to navigate
3. `Space` → start selection
4. `Enter` → copy selection
5. `Prefix ]` → paste

### Configuration Location
Your tmux config is managed by nix-darwin:
- Source: `.config/nix-config/home/modules/dev-tools.nix`
- After rebuilding, it's at: `~/.config/tmux/tmux.conf`
- Reload: `Prefix r` or `darwin-rebuild switch`

