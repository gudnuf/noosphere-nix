# Neovim Quick Start Guide

Your Neovim setup is configured with essential plugins and a deep blue theme that matches your terminal.

## Basic Vim Commands (You Already Know These)

- `i` - Insert mode
- `Esc` - Normal mode
- `:w` - Save
- `:q` - Quit
- `:wq` or `:x` - Save and quit
- `h/j/k/l` - Move left/down/up/right
- `dd` - Delete line
- `yy` - Yank (copy) line
- `p` - Paste
- `u` - Undo
- `Ctrl+r` - Redo

## Leader Key = Space

All custom shortcuts start with `Space`. When you press Space, **Which-Key** will show you available commands after a brief pause.

## Essential New Shortcuts

### File Navigation (Telescope)

| Shortcut | Action |
|----------|--------|
| `Space` `f` `f` | Find files (fuzzy search) |
| `Space` `f` `g` | Live grep (search in files) |
| `Space` `f` `b` | Find buffers (open files) |
| `Space` `f` `r` | Recent files |
| `Space` `f` `h` | Find help |

**In Telescope:**
- Type to filter results
- `Ctrl+n` / `Ctrl+p` - Navigate down/up
- `Enter` - Open file
- `Esc` - Close

### File Explorer (Neo-tree)

| Shortcut | Action |
|----------|--------|
| `Space` `e` | Toggle file explorer sidebar |

**In Neo-tree:**
- `j/k` - Move down/up
- `Enter` - Open file/folder
- `a` - Add file/folder
- `d` - Delete
- `r` - Rename
- `c` - Copy
- `x` - Cut
- `p` - Paste
- `?` - Show help

### Buffer Management

| Shortcut | Action |
|----------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `Space` `b` `d` | Delete buffer |

### Window Splits

| Shortcut | Action |
|----------|--------|
| `Space` `s` `v` | Split vertically |
| `Space` `s` `h` | Split horizontally |
| `Ctrl+h/j/k/l` | Navigate between splits |

### Quick Actions

| Shortcut | Action |
|----------|--------|
| `Space` `w` | Save file |
| `Space` `q` | Quit |
| `Space` `x` | Save and quit |
| `gcc` | Comment/uncomment line |
| `gc` (visual) | Comment/uncomment selection |

### LSP (Code Intelligence)

Works automatically for Nix files and other supported languages:

| Shortcut | Action |
|----------|--------|
| `g` `d` | Go to definition |
| `K` | Show hover info/documentation |
| `Space` `c` `a` | Code actions |
| `Space` `r` `n` | Rename symbol |

### Autocomplete

In insert mode:
- Start typing - suggestions appear automatically
- `Tab` - Select next suggestion
- `Shift+Tab` - Select previous suggestion
- `Enter` - Accept suggestion
- `Ctrl+Space` - Manually trigger completion
- `Ctrl+e` - Close completion menu

## Learning Tips

1. **Start Small**: Begin with just `Space` `f` `f` to find files and `Space` `e` for the file tree
2. **Use Which-Key**: Press `Space` and wait - it shows you what's available
3. **One New Shortcut Per Day**: Don't try to learn everything at once
4. **Keep Using Vim Basics**: Your existing vim knowledge still works perfectly

## Common Workflows

### Opening a File
```
1. Press Space f f
2. Type part of the filename
3. Press Enter
```

### Editing Multiple Files
```
1. Open first file (Space f f)
2. Open second file (Space f f)
3. Switch between them with Tab/Shift+Tab
```

### Searching in Files
```
1. Press Space f g
2. Type your search term
3. Navigate results with Ctrl+n/Ctrl+p
4. Press Enter to jump to match
```

### Using File Explorer
```
1. Press Space e
2. Navigate with j/k
3. Press Enter to open
4. Press Space e again to close
```

## Theme

Your Neovim uses **Tokyo Night** theme with transparent background, matching your terminal's deep blue aesthetic. All plugins use the same color scheme for consistency.

## Installed Plugins

- **Telescope**: Fuzzy finder for files, grep, buffers
- **Neo-tree**: File explorer sidebar
- **Treesitter**: Better syntax highlighting
- **LSP**: Code intelligence (autocomplete, go-to-definition, etc.)
- **Which-Key**: Shows available keybindings
- **Lualine**: Status line at bottom
- **Bufferline**: Buffer tabs at top
- **Gitsigns**: Git change indicators in gutter
- **Comment**: Easy code commenting
- **Autopairs**: Auto-closes brackets and quotes

## Getting Help

- `:help <topic>` - Built-in Vim help
- `Space` `f` `h` - Search help with Telescope
- `?` in Neo-tree - Show file explorer help
- Press `Space` and wait - Which-Key shows available commands

## Next Steps

1. Open a file: `nvim ~/.config/nix-config/flake.nix`
2. Try `Space` `f` `f` to find another file
3. Open file explorer with `Space` `e`
4. Practice navigating between buffers with `Tab`

Remember: **Press Space and watch Which-Key** - it's your guide to discovering new shortcuts!
