# Nix Config Cheat Sheet

## Quick Reference

| Task | Command |
|------|---------|
| Rebuild system | `nrs` or `darwin-rebuild switch --flake ~/.config/nix-config#nous` |
| Update flake inputs | `nfu` or `nix flake update ~/.config/nix-config` |
| Check flake | `nfc` or `nix flake check ~/.config/nix-config` |
| Edit config | `cd ~/.config/nix-config && $EDITOR .` |

---

## Shell: Zsh

### What It Does
Interactive shell with auto-suggestions, syntax highlighting, and smart completions.

### Key Features
- **Auto-suggestions**: Ghost text shows previous matching commands (press `→` to accept)
- **Syntax highlighting**: Valid commands are green, errors are red
- **Shared history**: Commands sync across all terminal sessions

### Usage

```bash
# History search - type partial command then:
↑ / ↓              # Search history by prefix

# Edit current command in vim:
Ctrl+X Ctrl+E

# Completion is case-insensitive
cd doc<tab>        # Matches Documents, documents, DOCUMENTS
```

### Configuration
**File**: `~/.config/nix-config/home/modules/shell.nix`

```nix
programs.zsh = {
  history.size = 50000;           # Change history size
  shellAliases = { ... };         # Add/modify aliases
  initContent = ''...'';          # Add custom zsh config
};
```

### Adding Aliases
```nix
shellAliases = {
  # Add your aliases here
  myalias = "some command";
};
```

---

## Prompt: Starship

### What It Does
Fast, minimal, cross-shell prompt showing git status, directory, and nix shell info.

### Prompt Format
```
~/.c/nix-config  main +1 -2
>                              # Green = last command succeeded
>                              # Red = last command failed
```

### Configuration
**File**: `~/.config/nix-config/home/modules/shell.nix`

```nix
programs.starship = {
  settings = {
    # Customize prompt segments
    character.success_symbol = "[>](bold green)";
    directory.truncation_length = 3;
    # Add more: https://starship.rs/config/
  };
};
```

### Common Customizations
```nix
# Show full path (no truncation)
directory.truncation_length = 0;

# Change prompt character
character.success_symbol = "[λ](bold green)";

# Show command duration
cmd_duration.disabled = false;
```

---

## Navigation: zoxide

### What It Does
Learns your most-used directories and lets you jump to them with partial names.

### Usage

```bash
z foo              # Jump to most frecent dir matching "foo"
z foo bar          # Jump to dir matching "foo" and "bar"
zi foo             # Interactive selection with fzf
zoxide query foo   # Show what z would match
zoxide query -l    # List all tracked directories
```

### How It Works
- Tracks directories you `cd` into
- Ranks by "frecency" (frequency + recency)
- Partial matches work: `z conf` → `~/.config`

### Configuration
**File**: `~/.config/nix-config/home/modules/shell.nix`

```nix
programs.zoxide = {
  enable = true;
  # Options: https://github.com/ajeetdsouza/zoxide
};
```

---

## Fuzzy Finder: fzf

### What It Does
Interactive fuzzy finder for files, history, and any list input.

### Key Bindings

| Binding | Action |
|---------|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files, insert path |
| `Alt+C` | Fuzzy find directories, cd into it |

### Usage

```bash
# Find and open file
vim $(fzf)

# Pipe anything to fzf
cat file.txt | fzf

# Preview files while selecting
fzf --preview 'bat --color=always {}'

# Multi-select with Tab
fzf -m
```

### Inside fzf

| Key | Action |
|-----|--------|
| `↑/↓` or `Ctrl+J/K` | Navigate |
| `Enter` | Select |
| `Tab` | Toggle selection (multi-mode) |
| `Ctrl+C` / `Esc` | Cancel |

### Configuration
**File**: `~/.config/nix-config/home/modules/shell.nix`

```nix
programs.fzf = {
  defaultOptions = [
    "--height 40%"
    "--layout=reverse"
    "--border"
  ];
  # Change file finder backend
  defaultCommand = "fd --type f --hidden --follow --exclude .git";
};
```

---

## File Listing: eza

### What It Does
Modern `ls` replacement with colors, icons, and git status.

### Usage

```bash
ls                 # Aliased to eza
ll                 # eza -la (long format, all files)
la                 # eza -a (all files)
lt                 # eza --tree

# Additional options
eza -l --git       # Show git status column
eza --tree -L 2    # Tree view, 2 levels deep
eza -lh            # Human-readable sizes
eza --icons=never  # Disable icons
```

### Configuration
**File**: `~/.config/nix-config/home/modules/shell.nix`

```nix
programs.eza = {
  icons = "auto";      # "auto", "always", "never"
  git = true;          # Show git status
  # extraOptions = [ "--group-directories-first" ];
};
```

---

## File Viewer: bat

### What It Does
`cat` with syntax highlighting, line numbers, and git integration.

### Usage

```bash
cat file.txt       # Aliased to bat
bat file.py        # Syntax highlighted
bat -p file.txt    # Plain mode (no line numbers/header)
bat -l json file   # Force language
bat --list-languages  # Show supported languages

# Show only specific lines
bat -r 10:20 file.txt

# Show non-printable characters
bat -A file.txt

# As a pager
export MANPAGER="bat -l man -p"
```

### Configuration
**File**: `~/.config/nix-config/home/modules/shell.nix`

```nix
programs.bat = {
  config = {
    theme = "TwoDark";                    # Change theme
    style = "numbers,changes,header";     # What to show
    # pager = "less -FR";
  };
};
```

### List Themes
```bash
bat --list-themes
```

---

## Search: ripgrep (rg)

### What It Does
Extremely fast recursive grep that respects `.gitignore`.

### Usage

```bash
rg pattern                  # Search current dir recursively
rg pattern path/            # Search specific path
rg -i pattern               # Case insensitive
rg -w word                  # Match whole words only
rg -l pattern               # List files only (no content)
rg -c pattern               # Count matches per file
rg -C 3 pattern             # Show 3 lines context
rg -t py pattern            # Search only Python files
rg -T js pattern            # Exclude JavaScript files
rg --hidden pattern         # Include hidden files
rg -g '*.json' pattern      # Glob filter
rg -v pattern               # Invert match
rg 'foo|bar'                # Regex OR
rg -e pat1 -e pat2          # Multiple patterns
rg -F 'literal.string'      # No regex interpretation
```

### Configuration
Create `~/.config/ripgrep/config`:
```
--smart-case
--hidden
--glob=!.git
```

Then set in shell.nix:
```nix
home.sessionVariables.RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
```

---

## Find: fd

### What It Does
Fast, user-friendly `find` alternative that respects `.gitignore`.

### Usage

```bash
fd pattern                  # Find files matching pattern
fd pattern path/            # Search in specific path
fd -e py                    # Find by extension
fd -e py -e js              # Multiple extensions
fd -t f pattern             # Files only
fd -t d pattern             # Directories only
fd -H pattern               # Include hidden
fd -I pattern               # Don't respect .gitignore
fd -x command {}            # Execute command on each result
fd -X command               # Execute command with all results
fd -d 2 pattern             # Max depth 2
fd '^test.*\.py$'           # Full regex
```

### Examples
```bash
# Delete all .DS_Store files
fd -H .DS_Store -x rm {}

# Find and open all markdown files
fd -e md -x code {}

# Find large files
fd -t f -x ls -lh {} | sort -k5 -h
```

---

## JSON: jq

### What It Does
Command-line JSON processor for parsing, filtering, and transforming JSON.

### Usage

```bash
# Pretty print
cat file.json | jq .

# Get field
jq '.name' file.json

# Get nested field
jq '.user.address.city' file.json

# Get array element
jq '.[0]' file.json
jq '.items[0]' file.json

# Iterate array
jq '.[]' file.json
jq '.items[].name' file.json

# Filter array
jq '.[] | select(.age > 30)' file.json

# Map/transform
jq '.items | map(.name)' file.json

# Raw output (no quotes)
jq -r '.name' file.json

# Compact output
jq -c '.' file.json

# Create new object
jq '{name: .title, count: .items | length}' file.json
```

### Common Patterns
```bash
# Get keys
jq 'keys' file.json

# Length
jq 'length' file.json
jq '.items | length' file.json

# Conditionals
jq 'if .status == "ok" then .data else empty end' file.json

# Sort
jq 'sort_by(.name)' file.json

# Unique
jq 'unique' file.json
```

---

## YAML: yq

### What It Does
Like jq but for YAML (and JSON) files.

### Usage

```bash
# Read YAML
yq '.name' file.yaml

# Convert YAML to JSON
yq -o json file.yaml

# Convert JSON to YAML
yq -P file.json

# Edit in place
yq -i '.version = "2.0"' file.yaml

# Merge files
yq '. * load("other.yaml")' base.yaml
```

---

## Git

### Configuration
**File**: `~/.config/nix-config/home/modules/git.nix`

### Shell Aliases

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `glog` | `git log --oneline --graph --decorate` |

### Git Aliases (use with `git <alias>`)

| Alias | Command |
|-------|---------|
| `co` | `checkout` |
| `br` | `branch` |
| `ci` | `commit` |
| `st` | `status` |
| `unstage` | `reset HEAD --` |
| `last` | `log -1 HEAD` |
| `lg` | `log --oneline --graph --decorate --all` |
| `amend` | `commit --amend --no-edit` |
| `undo` | `reset --soft HEAD~1` |
| `stash-all` | `stash save --include-untracked` |

### URL Shortcut
```bash
git clone gh:owner/repo    # Expands to git@github.com:owner/repo
```

### Delta (Diff Viewer)
Git diffs automatically use delta for side-by-side, syntax-highlighted output.

Navigate in delta:
| Key | Action |
|-----|--------|
| `n` | Next file |
| `N` | Previous file |
| `q` | Quit |

### Modifying Git Config
```nix
# In home/modules/git.nix
programs.git.settings = {
  user.name = "Your Name";
  user.email = "you@example.com";

  # Add more settings
  core.autocrlf = "input";
};
```

---

## GitHub CLI: gh

### What It Does
Official GitHub CLI for PRs, issues, repos, and more.

### Usage

```bash
# Auth
gh auth login

# Repos
gh repo create
gh repo clone owner/repo
gh repo view --web          # Open in browser

# Pull Requests
gh pr create
gh pr list
gh pr view 123
gh pr checkout 123
gh pr merge 123

# Issues
gh issue create
gh issue list
gh issue view 123

# Actions
gh run list
gh run view
gh run watch

# Gists
gh gist create file.txt
gh gist list
```

### Configuration
**File**: `~/.config/nix-config/home/modules/git.nix`

```nix
programs.gh = {
  settings = {
    git_protocol = "ssh";      # or "https"
    prompt = "enabled";
  };
};
```

---

## direnv

### What It Does
Automatically loads/unloads environment variables when entering/leaving directories.

### Usage

```bash
# Create .envrc in project directory
echo 'export FOO=bar' > .envrc

# Allow direnv to load it
direnv allow

# For Nix flakes
echo 'use flake' > .envrc
direnv allow

# For shell.nix
echo 'use nix' > .envrc
direnv allow
```

### Common .envrc Patterns

```bash
# Load nix flake
use flake

# Load shell.nix
use nix

# Set env vars
export DATABASE_URL="postgres://localhost/mydb"

# Add local bin to PATH
PATH_add bin

# Load .env file
dotenv

# Use specific Node version (with nix)
use flake "github:nix-community/nix-direnv"
```

### Configuration
**File**: `~/.config/nix-config/home/modules/dev-tools.nix`

```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;   # Faster flake loading
};
```

---

## tmux

### What It Does
Terminal multiplexer - multiple terminal sessions in one window, persistent sessions.

### Key Bindings (prefix: `Ctrl+B`)

| Binding | Action |
|---------|--------|
| `Ctrl+B` then `\|` | Split vertically |
| `Ctrl+B` then `-` | Split horizontally |
| `Ctrl+B` then `h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+B` then `H/J/K/L` | Resize panes |
| `Ctrl+B` then `c` | New window |
| `Ctrl+B` then `n` | Next window |
| `Ctrl+B` then `p` | Previous window |
| `Ctrl+B` then `0-9` | Go to window N |
| `Ctrl+B` then `d` | Detach session |
| `Ctrl+B` then `[` | Enter copy mode (vi keys) |
| `Ctrl+B` then `r` | Reload config |
| `Ctrl+B` then `?` | List all bindings |

### Usage

```bash
tmux                        # New session
tmux new -s name            # New named session
tmux ls                     # List sessions
tmux attach -t name         # Attach to session
tmux kill-session -t name   # Kill session
```

### Copy Mode (vi keys)
1. `Ctrl+B` then `[` to enter
2. Navigate with `h/j/k/l`
3. `Space` to start selection
4. `Enter` to copy
5. `Ctrl+B` then `]` to paste

### Configuration
**File**: `~/.config/nix-config/home/modules/dev-tools.nix`

```nix
programs.tmux = {
  keyMode = "vi";           # or "emacs"
  historyLimit = 50000;
  baseIndex = 1;            # Windows start at 1
  extraConfig = ''
    # Add custom config here
  '';
};
```

---

## Process Viewing: htop / bottom

### htop
```bash
htop                        # Launch
```
| Key | Action |
|-----|--------|
| `F5` | Tree view |
| `F6` | Sort by column |
| `F9` | Kill process |
| `/` | Search |
| `q` | Quit |

### bottom (btm)
```bash
btm                         # Launch
```
More modern alternative with graphs. Press `?` for help.

---

## HTTP Client: httpie

### What It Does
User-friendly HTTP client (alternative to curl).

### Usage

```bash
# GET request
http httpbin.org/get

# POST with JSON
http POST httpbin.org/post name=John age:=30

# Headers
http httpbin.org/headers Authorization:"Bearer token"

# Form data
http -f POST httpbin.org/post name=John

# Download file
http --download example.com/file.zip

# Only headers
http --headers httpbin.org/get

# Verbose (show request)
http -v httpbin.org/get
```

---

## SSH

### Configuration
**File**: `~/.config/nix-config/home/modules/dev-tools.nix`

Currently configured for **1Password SSH agent**. Keys are managed in 1Password and automatically available.

### Modifying SSH Config
```nix
programs.ssh = {
  matchBlocks = {
    # Catch-all config
    "*" = {
      addKeysToAgent = "yes";
      identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    # Host-specific config
    "github.com" = {
      user = "git";
      identityFile = "~/.ssh/github_key";
    };

    "myserver" = {
      hostname = "192.168.1.100";
      user = "admin";
      port = 2222;
    };
  };
};
```

---

## Nix Tools

### nixfmt
```bash
nixfmt file.nix             # Format file
nixfmt --check file.nix     # Check without modifying
```

### nil (Nix LSP)
Provides IDE features in editors that support LSP:
- Completion
- Hover documentation
- Go to definition
- Diagnostics

Configure in your editor (VS Code, Neovim, etc.)

### nix-tree
```bash
nix-tree                    # Browse current system closure
nix-tree .#darwinConfigurations.nous.system  # Browse specific derivation
```

---

## Nix Commands Quick Reference

```bash
# Rebuild and switch
darwin-rebuild switch --flake ~/.config/nix-config#nous
nrs                         # Alias

# Update inputs
nix flake update ~/.config/nix-config
nfu                         # Alias

# Check flake
nix flake check ~/.config/nix-config
nfc                         # Alias

# Show flake info
nix flake show ~/.config/nix-config
nix flake metadata ~/.config/nix-config

# Garbage collection
nix-collect-garbage -d      # Delete all old generations
nix-collect-garbage --delete-older-than 7d

# Search packages
nix search nixpkgs firefox

# Run package without installing
nix run nixpkgs#cowsay -- "Hello"

# Enter shell with package
nix shell nixpkgs#nodejs nixpkgs#yarn

# Show derivation info
nix derivation show nixpkgs#hello
```

---

## Adding New Packages

### System-wide (all users)
**File**: `~/.config/nix-config/modules/darwin/default.nix`

```nix
environment.systemPackages = with pkgs; [
  vim
  curl
  wget
  # Add packages here
];
```

### User-level (Home Manager)
**File**: `~/.config/nix-config/home/modules/dev-tools.nix`

```nix
home.packages = with pkgs; [
  ripgrep
  fd
  # Add packages here
];
```

### Homebrew Casks (GUI apps)
**File**: `~/.config/nix-config/hosts/darwin/default.nix`

```nix
homebrew = {
  casks = [
    "firefox"
    "visual-studio-code"
    "docker"
  ];
  brews = [
    # Homebrew formulae if needed
  ];
};
```

### After Adding Packages
```bash
nrs   # Rebuild system
```

---

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/nix-config/flake.nix` | Main entry point, inputs |
| `~/.config/nix-config/hosts/darwin/default.nix` | macOS system settings, Homebrew |
| `~/.config/nix-config/modules/darwin/default.nix` | macOS-specific modules |
| `~/.config/nix-config/modules/shared/default.nix` | Settings shared with NixOS |
| `~/.config/nix-config/home/default.nix` | Home Manager entry point |
| `~/.config/nix-config/home/modules/shell.nix` | Zsh, Starship, fzf, zoxide, eza, bat |
| `~/.config/nix-config/home/modules/git.nix` | Git, delta, gh |
| `~/.config/nix-config/home/modules/dev-tools.nix` | CLI tools, direnv, tmux, ssh |

---

## Troubleshooting

### Build fails
```bash
# Check for syntax errors
nix flake check ~/.config/nix-config

# Build without switching (to see errors)
darwin-rebuild build --flake ~/.config/nix-config#nous
```

### Package not found
```bash
# Search for correct package name
nix search nixpkgs packagename
```

### Revert to previous generation
```bash
# List generations
darwin-rebuild --list-generations

# Switch to specific generation
sudo /nix/var/nix/profiles/system-N-link/activate
```

### Clear nix store space
```bash
nix-collect-garbage -d
```
