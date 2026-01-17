# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix/nix-darwin configuration repository for macOS with Home Manager integration. The configuration uses:
- **nix-darwin** for macOS system management
- **Home Manager** for user-level package and dotfile management
- **Determinate Nix** installer (Nix settings managed externally, `nix.enable = false`)
- **Flakes** for declarative dependency management

The primary host is "nous" (aarch64-darwin), with a NixOS VM configuration for testing.

## Common Commands

### Building and Switching

```bash
# Rebuild system (most common command)
darwin-rebuild switch --flake ~/.config/nix-config#nous
# Or use alias:
nrs

# Build without switching (check for errors)
darwin-rebuild build --flake ~/.config/nix-config#nous

# Check flake for issues
nix flake check ~/.config/nix-config
# Or use alias:
nfc
```

### Updating Dependencies

```bash
# Update all flake inputs
nix flake update ~/.config/nix-config
# Or use alias:
nfu

# Update specific input
nix flake lock --update-input nixpkgs ~/.config/nix-config
```

### Testing and Development

```bash
# Format Nix files
nixfmt **/*.nix

# Show flake structure
nix flake show ~/.config/nix-config

# Browse dependency tree
nix-tree

# Garbage collection
nix-collect-garbage -d
```

## Architecture

### Flake Structure

The repository follows a modular architecture with clear separation of concerns:

**Entry Point**: `flake.nix`
- Defines inputs: nixpkgs, nix-darwin, home-manager, claude-code, agent-skills, anthropic-skills
- Contains helper functions `mkDarwinSystem` and `mkNixOSSystem`
- Exports `darwinConfigurations.nous` and `nixosConfigurations.nixos-vm`

**Configuration Layers** (applied in order):
1. **Host-specific** (`hosts/darwin/default.nix` or `hosts/nixos/default.nix`)
2. **OS-shared modules** (`modules/shared/default.nix`)
3. **OS-specific modules** (`modules/darwin/default.nix` or `modules/nixos/default.nix`)
4. **Home Manager** (`home/default.nix` with imports from `home/modules/`)

### Module Organization

**System-Level Configuration**:
- `hosts/darwin/default.nix`: Hostname, user setup, macOS defaults (Dock, Finder, trackpad), Homebrew
- `modules/darwin/default.nix`: System packages, shells, fonts
- `modules/shared/default.nix`: Cross-platform settings (allowUnfree, environment variables)

**User-Level Configuration** (Home Manager):
- `home/default.nix`: Entry point, imports shell/git/dev-tools/skills modules
- `home/modules/shell.nix`: Zsh, Starship, fzf, zoxide, eza, bat
- `home/modules/git.nix`: Git config, delta, GitHub CLI
- `home/modules/dev-tools.nix`: CLI tools, direnv, tmux, SSH
- `home/modules/skills.nix`: Claude Code skills management via agent-skills-nix

### Key Design Patterns

**Nix Management**: This config uses Determinate Nix installer, so `nix.enable = false` is set in host configs. Do not add `nix.*` options in modules.

**Package Management Hierarchy**:
1. System-wide packages → `modules/darwin/default.nix` → `environment.systemPackages`
2. User packages → `home/modules/dev-tools.nix` → `home.packages`
3. GUI applications → `hosts/darwin/default.nix` → `homebrew.casks`

**Username/Hostname Passing**: The `username` and `hostname` variables are passed through `specialArgs` to all modules, allowing reusable configurations.

**Home Manager Integration**: Home Manager is integrated as a module in the darwin/NixOS configurations, not as a standalone tool. It shares `nixpkgs` with the system config via `useGlobalPkgs = true`.

## Adding Packages

### CLI Tools (User-level)
Edit `home/modules/dev-tools.nix` and add to `home.packages`:
```nix
home.packages = with pkgs; [
  ripgrep
  your-package-here
];
```

### System Packages (All Users)
Edit `modules/darwin/default.nix` and add to `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  vim
  your-package-here
];
```

### GUI Applications (Homebrew)
Edit `hosts/darwin/default.nix`:
```nix
homebrew.casks = [
  "visual-studio-code"
  "your-app-here"
];
```

Then rebuild: `nrs`

## Managing Claude Code Skills

Skills are managed declaratively through the `agent-skills-nix` flake. Configuration is in `home/modules/skills.nix`.

### Enable a Skill

Add the skill name to the enable list in `home/modules/skills.nix`:
```nix
skills.enable = [
  "skill-creator"
  "new-skill-name"
];
```

### Add a New Skill Source

1. Add input to `flake.nix`:
```nix
inputs = {
  my-skills = {
    url = "github:username/skills-repo";
    flake = false;
  };
};
```

2. Add to outputs: `outputs = inputs@{ ..., my-skills, ... }:`

3. Configure in `home/modules/skills.nix`:
```nix
sources.my-skills = {
  path = inputs.my-skills;
  subdir = "skills";  # if needed
};
```

### Create a Local Skill

1. Create directory: `mkdir -p skills/my-skill`
2. Add `SKILL.md` file with skill content
3. The `local` source in `skills.nix` points to `../../skills`
4. Enable in `skills.enable` list
5. Stage files: `git add skills/`

### Update Remote Skills

```bash
# Update specific skill source
nix flake lock --update-input anthropic-skills

# Update all inputs
nfu
```

### File Locations

| Purpose | Path |
|---------|------|
| Skills config | `home/modules/skills.nix` |
| Local skills | `skills/` |
| Synced output | `~/.claude/skills/` |

## Modifying Configurations

### Shell Aliases
Edit `home/modules/shell.nix` → `programs.zsh.shellAliases`

### Git Settings
Edit `home/modules/git.nix` → `programs.git.settings`

### macOS System Preferences
Edit `hosts/darwin/default.nix` → `system.defaults`

### Adding New Modules
1. Create `.nix` file in appropriate directory
2. Import in parent `default.nix` (e.g., add to `imports = [ ... ]` in `home/default.nix`)
3. Rebuild with `nrs`

## Git Commit Guidelines

Commit after every significant configuration change to maintain a clear history and enable easy rollback. Use concise, imperative commit messages that describe what changed.

### When to Commit

- After adding/removing packages
- After modifying system preferences or module settings
- After updating flake inputs (`flake.lock` changes)
- Before and after experimental changes
- After successful rebuild of working configuration

### Commit Message Format

**Pattern**: `<action>: <what> [context]`

**Examples**:
```bash
# Package changes
git commit -m "add: ripgrep and fd to dev-tools"
git commit -m "remove: unused GUI apps from homebrew casks"
git commit -m "update: flake inputs (nixpkgs 24.05 -> 24.11)"

# Configuration changes
git commit -m "update: zsh history size to 100000"
git commit -m "enable: tmux mouse support"
git commit -m "fix: starship prompt git status colors"

# System settings
git commit -m "update: dock autohide and icon size"
git commit -m "enable: three-finger drag on trackpad"

# Module/structure changes
git commit -m "add: neovim module for editor config"
git commit -m "refactor: split shell.nix into zsh and starship modules"

# Flake maintenance
git commit -m "update: flake.lock (weekly update)"
git commit -m "add: nix-darwin input for system management"
```

### Actions to Use

- `add` - New packages, modules, or features
- `remove` - Deleted packages, modules, or settings
- `update` - Changed versions, modified settings, or flake updates
- `fix` - Bug fixes or corrections
- `enable`/`disable` - Toggling features
- `refactor` - Restructuring without functional changes

### Multi-File Changes

For changes spanning multiple modules, commit together with a descriptive message:
```bash
git commit -m "add: development tools (ripgrep, fd, jq) and configure fzf integration"
```

### Testing Before Commit

```bash
# Ensure configuration builds
nrs

# Then commit if successful
git add .
git commit -m "update: <your changes>"
```

## Important Constraints

- **Username**: Hardcoded to "claude" in `flake.nix:24`
- **Hostname**: "nous" for darwin, "nixos-vm" for NixOS
- **StateVersion**: home-manager uses "24.05", darwin uses 5
- **SSH**: Configured for 1Password SSH agent at `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- **Overlay**: claude-code package comes from overlay at `claude-code.overlays.default`

## Troubleshooting

**Build failures**: Run `nix flake check ~/.config/nix-config` to identify syntax errors or evaluation issues.

**Rollback**: If a rebuild breaks something, list generations with `darwin-rebuild --list-generations`, then activate a previous one with `sudo /nix/var/nix/profiles/system-N-link/activate`.

**Module conflicts**: Ensure `nix.enable = false` remains in darwin hosts when using Determinate Nix.
