# CLAUDE.md

Nix/nix-darwin configuration for macOS with Home Manager integration. Uses Determinate Nix installer (external Nix management, `nix.enable = false`).

## Tech Stack

| Component | Purpose |
|-----------|---------|
| nix-darwin | macOS system management |
| Home Manager | User-level packages & dotfiles |
| Flakes | Declarative dependencies |
| agent-skills-nix | Claude Code skills management |

## File Structure

```
flake.nix              # Entry point, defines inputs & system builders
├── hosts/darwin/      # Host-specific: hostname, user, macOS defaults, Homebrew
├── modules/
│   ├── darwin/        # System packages, shells, fonts
│   └── shared/        # Cross-platform settings (allowUnfree, env vars)
├── home/
│   ├── default.nix    # Home Manager entry point
│   └── modules/       # shell, git, dev-tools, skills
├── skills/            # Local Claude Code skills (syncs to ~/.claude/skills/)
├── secrets.nix        # Your secrets (git-ignored, not committed)
└── secrets.nix.template  # Template for secrets file
```

## Common Commands

| Command | Alias | Purpose |
|---------|-------|---------|
| `darwin-rebuild switch --flake ~/.config/nix-config#nous` | `nrs` | Rebuild & activate |
| `nix flake update ~/.config/nix-config` | `nfu` | Update all inputs |
| `nix flake check ~/.config/nix-config` | `nfc` | Check for errors |
| `nixfmt **/*.nix` | - | Format Nix files |
| `nix-collect-garbage -d` | - | Clean old generations |

## Critical Patterns

### Configuration Layers (Applied in Order)

1. **Host** (`hosts/darwin/default.nix`) - Hostname, user, system settings
2. **Shared** (`modules/shared/default.nix`) - Cross-platform config
3. **OS-specific** (`modules/darwin/default.nix`) - System packages
4. **Home Manager** (`home/default.nix`) - User-level config

### Nix Management

This config uses **Determinate Nix installer**. Never add `nix.*` options - they're managed externally. `nix.enable = false` must stay in host configs.

### Package Management

| Type | Location | Usage |
|------|----------|-------|
| System packages | `modules/darwin/default.nix` | `environment.systemPackages` |
| User CLI tools | `home/modules/dev-tools.nix` | `home.packages` |
| GUI applications | `hosts/darwin/default.nix` | `homebrew.casks` |

### Skills Management

Configure in `home/modules/skills.nix`. Two sources enabled:
- `anthropic` - Official skills from flake input
- `local` - Skills in `./skills/` directory

**Enable a skill:**
```nix
skills.enable = [
  "skill-creator"
  "your-skill-name"
];
```

**Add remote skill source:**
1. Add input to `flake.nix`: `my-skills = { url = "github:user/repo"; flake = false; }`
2. Configure in `skills.nix`: `sources.my-skills = { path = inputs.my-skills; };`
3. Enable in `skills.enable` list

**Create local skill:**
1. Create `skills/my-skill/SKILL.md`
2. Add to `skills.enable` list
3. Stage with `git add skills/`

Skills sync to `~/.claude/skills/` on rebuild.

### Secrets Management

Sensitive data (API tokens, credentials) are stored in `secrets.nix`, which is git-ignored and never committed.

**File structure:**
```
secrets.nix.template    # Template showing the format
secrets.nix            # Your actual secrets (git-ignored)
```

**Setup:**
1. Copy template: `cp secrets.nix.template secrets.nix`
2. Add your secrets:
   ```nix
   {
     GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_your_token";
     API_KEY = "your_key";
   }
   ```
3. Rebuild: `nrs`

**How it works:**

| Environment | Method | Availability |
|-------------|--------|--------------|
| Shell sessions | `home.sessionVariables` | Terminal, scripts |
| GUI apps (Claude Code, etc.) | launchd agent | All applications |

**Implementation** (`home/default.nix`):
- Conditionally imports `secrets.nix` if it exists
- Merges secrets into `home.sessionVariables` for shell access
- Uses launchd agent to set environment variables for GUI apps

**For GUI apps on macOS:**

A launchd agent (`~/Library/LaunchAgents/com.user.setenv.plist`) runs at login to make secrets available to GUI applications like Claude Code. This is required because macOS GUI apps don't inherit shell environment variables.

**Manual launchd setup** (if needed):
```bash
# Set immediately (current session)
launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "your_token"

# Verify
launchctl getenv GITHUB_PERSONAL_ACCESS_TOKEN
```

**Adding new secrets:**
1. Edit `secrets.nix` with new key-value pairs
2. Update `~/Library/LaunchAgents/com.user.setenv.plist` with new variables
3. Reload: `launchctl unload ~/Library/LaunchAgents/com.user.setenv.plist && launchctl load ~/Library/LaunchAgents/com.user.setenv.plist`
4. Restart affected GUI apps

**Security notes:**
- `secrets.nix` is in `.gitignore` - never committed
- `secrets.nix.template` shows structure without real values
- If `secrets.nix` is missing, config still works (empty set)

## Adding Packages

1. Choose location based on table above
2. Add package name to appropriate list
3. Rebuild with `nrs`

Example (user CLI tool):
```nix
# home/modules/dev-tools.nix
home.packages = with pkgs; [
  ripgrep
  your-package  # Add here
];
```

## Git Workflow

Commit after significant changes for easy rollback:
```bash
# Test build first
nrs

# Commit if successful
git add .
git commit -m "action: brief description"
```

**Common actions:** `add`, `remove`, `update`, `fix`, `enable`, `disable`, `refactor`

## Important Constraints

| Setting | Value | Location |
|---------|-------|----------|
| Username | `claude` | `flake.nix:35` |
| Hostname (darwin) | `nous` | Host-specific |
| Hostname (NixOS) | `nixos-vm` | Host-specific |
| State version (darwin) | `5` | Host config |
| State version (home) | `24.05` | `home/default.nix` |
| SSH agent | 1Password | `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` |

## Troubleshooting

**Build fails**: Run `nfc` to identify syntax/evaluation errors

**Rollback**:
```bash
darwin-rebuild --list-generations
sudo /nix/var/nix/profiles/system-N-link/activate
```

**Module conflicts**: Ensure `nix.enable = false` in host configs (required for Determinate Nix)

## Module Details

### Shell (`home/modules/shell.nix`)
- Zsh: autosuggestion, syntax highlighting, 50k history
- Starship: custom prompt with git status & nix-shell indicator
- Tools: fzf, zoxide, eza, bat
- Aliases: git shortcuts (g, gs, ga, gc, gp, gl), nix shortcuts (nrs, nfu, nfc)

### Dev Tools (`home/modules/dev-tools.nix`)
- Search: ripgrep, fd, tree, jq, yq
- Nix: nixfmt, nil (LSP), nix-tree
- Environments: direnv with nix-direnv
- Terminal: tmux (vi bindings, mouse support)
- AI: claude-code CLI

### macOS Defaults (`hosts/darwin/default.nix`)
- Dock: autohide, 48px icons, magnification, show-recents off
- Finder: show extensions, default list view, search current folder
- Trackpad: tap-to-click, three-finger drag
- Touch ID for sudo enabled
