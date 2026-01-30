# nix-config

Declarative Nix configuration for macOS and NixOS machines using Flakes, nix-darwin, and Home Manager.

## What This Is

A single flake that manages multiple machines:

- **macOS** (nix-darwin) - Development workstations
- **NixOS** - Local VMs and cloud servers
- **Home Manager** - User environment (shell, editor, tools)

Everything is declarative, reproducible, and version-controlled.

## Quick Start

### Prerequisites

- [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) (recommended for macOS)
- Or standard Nix with flakes enabled

### Clone and Build

```bash
# Clone to the expected location
git clone https://github.com/gudnuf/nix-config.git ~/.config/nix-config
cd ~/.config/nix-config

# Build and activate (macOS)
darwin-rebuild switch --flake .#nous

# Build and activate (NixOS)
sudo nixos-rebuild switch --flake .#nixos-vm
```

### Create Your Own Host

1. Copy an existing host config from `hosts/`
2. Update `flake.nix` with your hostname
3. Modify packages and settings to your needs
4. Rebuild

## Structure

```
flake.nix              # Entry point - inputs and system definitions
├── hosts/
│   ├── darwin/        # macOS system config (hostname, defaults, Homebrew)
│   ├── nixos/         # NixOS VM config
│   └── hetzner/       # Cloud server config
├── modules/
│   ├── shared/        # Cross-platform settings
│   ├── darwin/        # macOS system packages
│   └── nixos/         # NixOS services (SSL, firewall, etc.)
├── home/
│   └── modules/       # User config (shell, git, neovim, tools)
└── skills/            # Claude Code skills (optional)
```

## Key Features

### Shell Environment
- **Zsh** with autosuggestion, syntax highlighting, 50k history
- **Starship** prompt with git status
- **fzf** fuzzy finder, **zoxide** smart cd, **eza** modern ls

### Development Tools
- ripgrep, fd, jq, yq, httpie, lazygit
- Neovim with LSP, Treesitter, Telescope
- direnv for per-project environments

### macOS Defaults
- Caps Lock → Control
- Touch ID for sudo (works in tmux)
- Tap-to-click, three-finger drag
- Dock auto-hide, Finder improvements

### Security
- SSH signing for Git commits (FIDO2 keys)
- 1Password SSH agent integration
- Declarative secrets management

## Common Commands

```bash
# Rebuild and switch (macOS)
darwin-rebuild switch --flake ~/.config/nix-config#nous

# Rebuild and switch (NixOS)
sudo nixos-rebuild switch --flake ~/.config/nix-config#nixos-vm

# Update all inputs
nix flake update

# Check for errors
nix flake check

# Test a package without installing
nix shell nixpkgs#package-name

# Clean old generations
nix-collect-garbage -d
```

After initial setup, use the aliases: `nrs` (rebuild), `nfu` (update), `nfc` (check).

## Adding Packages

**System packages** (available to all users):
```nix
# modules/darwin/default.nix or modules/nixos/default.nix
environment.systemPackages = with pkgs; [
  your-package
];
```

**User packages** (Home Manager):
```nix
# home/modules/dev-tools.nix
home.packages = with pkgs; [
  your-package
];
```

**GUI apps** (macOS via Homebrew):
```nix
# hosts/darwin/default.nix
homebrew.casks = [
  "your-app"
];
```

## Customization

### Fork for Your Own Use

1. Fork this repo
2. Update `flake.nix`:
   - Change username from `claude` to yours
   - Change hostname from `nous` to yours
3. Update `home/modules/git.nix` with your Git identity
4. Remove or modify files you don't need
5. Rebuild

### Secrets

Copy the template and add your secrets:

```bash
cp secrets.nix.template secrets.nix
# Edit secrets.nix with your API keys, tokens, etc.
```

The `secrets.nix` file is git-ignored.

## Documentation

- [CLAUDE.md](CLAUDE.md) - Detailed configuration patterns
- [GIT-SIGNING.md](GIT-SIGNING.md) - FIDO2 SSH commit signing setup
- [SECRETS.md](SECRETS.md) - Secrets management
- [CHEATSHEET.md](CHEATSHEET.md) - Quick reference

## Requirements

| Component | Version |
|-----------|---------|
| Nix | 2.18+ with flakes |
| macOS | 13+ (Ventura or later) |
| NixOS | 24.05+ |

## License

MIT
