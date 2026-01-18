# CLAUDE.nous.md

**Host:** nous (macOS/Darwin)
**User:** claude
**Config Location:** `~/.config/nix-config`
**System Manager:** nix-darwin + Home Manager (Determinate Nix installer)

## How You're Running

You (Claude Code) are running on this machine as:
- **Binary:** `claude-code` installed via Nix (`home/modules/dev-tools.nix:45`)
- **Shell:** zsh (configured via Home Manager)
- **Working Directory:** Typically starts in `~` but can navigate anywhere
- **Skills:** Managed declaratively via `agent-skills-nix` in `home/modules/skills.nix`
  - Skills sync from nix-config to `~/.claude/skills/` on rebuild
  - Currently enabled: `skill-creator`, `nix-skills-management`, `update-context`

## Modifying Global State

All system configuration is declarative via Nix. To modify this machine:

### 1. Edit Configuration Files

Choose the appropriate file based on what you're changing:

| What to Change | File | Examples |
|----------------|------|----------|
| System packages | `modules/darwin/default.nix` | vim, curl, wget |
| User CLI tools | `home/modules/dev-tools.nix` | ripgrep, fd, jq, claude-code |
| GUI applications | `hosts/darwin/default.nix` | Homebrew casks (utm) |
| Shell config | `home/modules/shell.nix` | aliases, zsh settings, starship |
| Git config | `home/modules/git.nix` | git aliases, user settings |
| Skills | `home/modules/skills.nix` | Claude Code skills to enable |
| macOS defaults | `hosts/darwin/default.nix` | Dock, Finder, trackpad settings |
| Secrets/tokens | `secrets.nix` | API keys, credentials (git-ignored) |

### 2. Apply Changes

```bash
nrs  # Alias for: sudo darwin-rebuild switch --flake ~/.config/nix-config#nous
```

This rebuilds and activates the new configuration atomically. If it fails, the old configuration remains active.

### 3. Rollback (if needed)

```bash
darwin-rebuild --list-generations
sudo /nix/var/nix/profiles/system-N-link/activate
```

## System Architecture

### Configuration Layers (Load Order)

1. **Flake** (`flake.nix`) - Defines inputs, outputs, and system builder
2. **Host** (`hosts/darwin/default.nix`) - Hostname, user, macOS defaults, Homebrew
3. **Shared** (`modules/shared/default.nix`) - Cross-platform settings (allowUnfree, etc.)
4. **Darwin** (`modules/darwin/default.nix`) - System packages, shells, fonts
5. **Home Manager** (`home/default.nix`) - User-level packages and dotfiles
   - Shell (`home/modules/shell.nix`)
   - Dev tools (`home/modules/dev-tools.nix`)
   - Git (`home/modules/git.nix`)
   - Skills (`home/modules/skills.nix`)

### Critical Constraints

| Setting | Value | Why | Location |
|---------|-------|-----|----------|
| `nix.enable` | `false` | Using Determinate Nix (external) | `hosts/darwin/default.nix:24` |
| Username | `claude` | Fixed in flake | `flake.nix` |
| Hostname | `nous` | macOS machine identifier | `flake.nix` |
| State version | `5` | Darwin backwards compat | `hosts/darwin/default.nix:29` |
| Home version | `24.05` | Home Manager compat | `home/default.nix` |

**Never add `nix.*` options** - they're managed by Determinate Nix installer.

## Installed Packages

### System-Wide (via nix-darwin)

Located in `modules/darwin/default.nix`:
- vim, curl, wget
- Shells: bash, zsh
- Fonts: JetBrains Mono Nerd Font, Fira Code Nerd Font

### User CLI Tools (via Home Manager)

Located in `home/modules/dev-tools.nix`:
- **Search:** ripgrep, fd, tree, jq, yq
- **Viewers:** less, glow (markdown), bat (cat replacement)
- **Network:** curl, wget, httpie
- **Process:** htop, bottom
- **Compression:** zip, unzip, p7zip
- **Nix:** nixfmt, nil (LSP), nix-tree
- **Dev:** gnumake, cmake, lazygit
- **AI:** claude-code (you!)

### GUI Applications (via Homebrew)

Located in `hosts/darwin/default.nix`:
- utm (Virtual machine host for NixOS testing)

## Shell Environment

### Zsh Configuration (`home/modules/shell.nix`)

**Features:**
- Auto-suggestions, syntax highlighting, completion
- 50k history with deduplication and sharing
- Modern replacements: `eza` (ls), `bat` (cat)
- Starship prompt with deep blue theme
- fzf fuzzy finder (Ctrl+R, Ctrl+T)
- zoxide smart directory jumping

**Key Aliases:**
```bash
# Nix system management
nrs   # Rebuild and switch
nfu   # Update flake inputs
nfc   # Check flake for errors

# Git shortcuts
g, gs, ga, gc, gp, gl, gd, gco, gb, glog

# Navigation
.., ..., ....
ls -> eza, ll -> eza -la, cat -> bat
```

### Tools Integration

- **direnv:** Auto-loads per-directory Nix environments (`.envrc` files)
- **tmux:** Terminal multiplexer with deep blue theme, vi bindings, Touch ID support
- **SSH:** 1Password agent integration for key management (config managed by Home Manager)
  - GitHub: dedicated ED25519 key at `~/.ssh/id_ed25519_github` (user: gudnuf)
- **Git:** Configured via `home/modules/git.nix`

## Skills Management

Skills are managed **entirely through Nix** at `home/modules/skills.nix`.

### Current Configuration

```nix
sources.anthropic = {
  path = inputs.anthropic-skills;  # Official skills from flake input
  subdir = "skills";
};

sources.local = {
  path = ../../skills;  # Local skills in ./skills/ directory
};

skills.enable = [
  "skill-creator"
  "nix-skills-management"
  "update-context"
];
```

### How Skills Work

1. **Nix builds** skills from sources (anthropic + local)
2. **Symlinks** them to `~/.claude/skills/` on rebuild
3. **Claude Code** loads skills from `~/.claude/skills/` at startup

### To Modify Skills

**Enable/disable a skill:**
1. Edit `home/modules/skills.nix`, modify `skills.enable` list
2. Run `nrs` to rebuild
3. Restart Claude Code session

**Add a new local skill:**
1. Create `skills/your-skill-name/SKILL.md`
2. Add `"your-skill-name"` to `skills.enable`
3. Stage skill: `git add skills/your-skill-name/`
4. Run `nrs` to activate

**Add a remote skill source:**
1. Add input to `flake.nix`: `my-skills = { url = "github:user/repo"; flake = false; }`
2. Add source in `skills.nix`: `sources.my-skills = { path = inputs.my-skills; };`
3. Enable skills from that source
4. Run `nfu && nrs` to fetch and activate

### Skill Discovery

```bash
nix run .#skills-list  # List all available skills from all sources
```

## macOS System Defaults

Configured declaratively in `hosts/darwin/default.nix:35-72`:

**Keyboard:**
- Caps Lock → Control
- Fast key repeat (2ms, 15ms initial)

**Trackpad:**
- Tap to click enabled
- Three-finger drag enabled
- Right-click enabled

**Dock:**
- Auto-hide enabled
- No recent applications
- No spaces rearrangement
- Minimize to application

**Finder:**
- Show all extensions
- Show path bar and status bar
- Quit menu item enabled
- Disable extension change warning

**Security:**
- Touch ID for sudo (works in tmux via pam_reattach)

## Secrets Management

**File:** `secrets.nix` (git-ignored, never committed)
**Template:** `secrets.nix.template`

Secrets are imported into `home.sessionVariables` for shell access and can be set in launchd for GUI apps.

See `SECRETS.md` for complete documentation.

## Common Workflows

### Add a New Package

1. Determine type (system/user CLI/GUI)
2. Edit appropriate file (see "Modifying Global State" table)
3. Add to package list
4. `nrs` to rebuild
5. `git add . && git commit -m "add: package-name"`

### Update All Packages

```bash
nfu   # Update flake inputs (nixpkgs, home-manager, etc.)
nrs   # Rebuild with updated inputs
```

### Test a Package Without Installing

```bash
nix shell nixpkgs#package-name
```

### Debug Build Failures

```bash
nfc   # Check flake for syntax/evaluation errors
nix flake show ~/.config/nix-config  # Show outputs
nixfmt **/*.nix  # Format all Nix files
```

### Clean Old Generations

```bash
nix-collect-garbage -d  # Delete old system generations
```

## How to Update This File

This file should be updated whenever:
- New packages/tools are installed on this host
- System configuration patterns change
- New skills are added
- Workflows are established

**Use the `/update-host-context` skill** for guidance on:
- When and how to update host-specific CLAUDE.md files
- Adding new hosts to the system
- Keeping documentation in sync with configuration
- Best practices for host context maintenance

You can also use `/update-context` for general context file maintenance following best practices.

## Related Files

- `CLAUDE.md` - General nix-config structure and patterns (repo-wide)
- `SECRETS.md` - Secrets management documentation
- `skills/update-host-context/SKILL.md` - Skill for maintaining host-specific context
- `skills/update-context/SKILL.md` - Skill for maintaining CLAUDE.md files
