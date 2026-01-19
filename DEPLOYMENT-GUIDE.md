# NixOS Cloud Deployment Guide

Deploy identical development environments across cloud instances using Nix flakes and nixos-infect.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Local Machine (nous - macOS)                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ~/.config/nix-config/                                   │   │
│  │  ├── flake.nix          # Defines all system configs     │   │
│  │  ├── hosts/hetzner/     # Cloud server config            │   │
│  │  ├── modules/nixos/     # Shared NixOS modules           │   │
│  │  ├── home/              # Home Manager (shell, tools)    │   │
│  │  └── skills/            # Claude Code skills             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                    nix run .#deploy-hetzner                     │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │ rsync + ssh
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Cloud Instance (hetzner - NixOS)                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Identical environment:                                  │   │
│  │  • zsh + starship + fzf + zoxide                        │   │
│  │  • neovim with treesitter + LSP                         │   │
│  │  • claude-code with skills + context                    │   │
│  │  • git, ripgrep, fd, jq, etc.                           │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### 1. SSH Key

Generate or use an existing ED25519 key:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Add the public key to `hosts/hetzner/default.nix`:

```nix
users.users.${username}.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... your-email@example.com"
];
```

### 2. Hetzner API Token

1. Log into [Hetzner Cloud Console](https://console.hetzner.cloud/)
2. Select project → Security → API Tokens → Generate API Token
3. Save token to `secrets.nix`:

```nix
{
  HCLOUD_TOKEN = "your-token-here";
}
```

### 3. hcloud CLI

Installed via nix-config. Set token before use:

```bash
export HCLOUD_TOKEN="$(nix eval --raw -f secrets.nix HCLOUD_TOKEN)"
```

Or add to your shell config for persistence.

## Deploy a New Instance

### Step 1: Create Server

```bash
# Upload SSH key (one-time)
hcloud ssh-key create --name "my-key" --public-key-from-file ~/.ssh/id_ed25519.pub

# Create Debian server
hcloud server create \
  --name my-server \
  --image debian-12 \
  --type cx23 \
  --ssh-key "my-key"
```

Note the IP address from output.

### Step 2: Run nixos-infect

```bash
ssh root@<IP> "curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.11 bash -x"
```

Server reboots into NixOS (~3-5 minutes).

### Step 3: Configure Host

Create host-specific files:

```bash
mkdir -p hosts/my-server
```

**hosts/my-server/default.nix:**
```nix
{ lib, pkgs, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  networking.hostName = hostname;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA... your-key"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";
}
```

**Get hardware config from server:**
```bash
ssh root@<IP> "cat /etc/nixos/hardware-configuration.nix" > hosts/my-server/hardware-configuration.nix
ssh root@<IP> "cat /etc/nixos/networking.nix" > hosts/my-server/networking.nix
```

### Step 4: Add to Flake

In `flake.nix`, add the configuration:

```nix
nixosConfigurations = {
  # ... existing configs ...

  my-server = mkHetznerSystem {
    hostname = "my-server";
    targetHost = "<IP>";
  };
};
```

Create context file `CLAUDE.my-server.md` (required by Home Manager).

### Step 5: Deploy

```bash
# Stage new files
git add hosts/my-server/ CLAUDE.my-server.md

# Deploy
nix run .#deploy-hetzner  # Or create a new deploy app for this server
```

## Deploy Commands

### Quick Deploy (existing server)

```bash
cd ~/.config/nix-config/.trees/nixos-infect
nix run .#deploy-hetzner
```

### Manual Deploy

```bash
# Copy config to server
rsync -avz --exclude='.git' --exclude='.trees' ./ claude@<IP>:/tmp/nixos-config/

# Build and switch on server
ssh claude@<IP> "sudo cp -r /tmp/nixos-config /etc/nixos-config && \
  sudo nixos-rebuild switch --flake /etc/nixos-config#<config-name>"
```

## Post-Deploy Setup

### Authenticate Claude Code

```bash
ssh claude@<IP>
claude
# Type: /login
# Follow OAuth flow or enter API key
```

### Verify Installation

```bash
ssh claude@<IP> "claude --version && ls ~/.claude/skills/"
```

## Configuration Structure

| Path | Purpose |
|------|---------|
| `flake.nix` | Entry point, defines all systems |
| `hosts/<name>/` | Host-specific config (hardware, networking, bootloader) |
| `modules/nixos/` | Shared NixOS modules (ssh, firewall, packages) |
| `modules/shared/` | Cross-platform settings |
| `home/` | User environment (shell, editor, tools) |
| `home/modules/skills.nix` | Claude Code skills configuration |
| `skills/` | Local skill definitions |
| `CLAUDE.<hostname>.md` | Host-specific Claude context |

## Adding Custom Deploy Scripts

Add to `flake.nix`:

```nix
apps.aarch64-darwin.deploy-my-server = {
  type = "app";
  program = toString (pkgsDarwin.writeShellScript "deploy-my-server" ''
    set -euo pipefail
    TARGET="claude@<IP>"
    FLAKE_DIR="''${FLAKE_DIR:-$(pwd)}"

    ${pkgsDarwin.rsync}/bin/rsync -avz --delete \
      --exclude='.git' --exclude='.trees' --exclude='result' \
      -e "ssh -o StrictHostKeyChecking=no" \
      "$FLAKE_DIR/" "$TARGET:/tmp/nixos-config/"

    ssh -o StrictHostKeyChecking=no "$TARGET" \
      "sudo cp -r /tmp/nixos-config /etc/nixos-config && \
       sudo nixos-rebuild switch --flake /etc/nixos-config#my-server"
  '');
};
```

## Server Management

### List Servers
```bash
hcloud server list
```

### Delete Server
```bash
hcloud server delete <name>
```

### SSH Access
```bash
ssh claude@<IP>           # Normal user (recommended)
# Root login disabled by default for security
```

### Check Deployment Status
```bash
ssh claude@<IP> "nixos-version && systemctl is-system-running"
```

## What Gets Deployed

Each instance receives:

**System:**
- NixOS with flakes enabled
- SSH hardening (fail2ban, no root login, key-only auth)
- Firewall (SSH + mosh only)
- zram swap

**User Environment (Home Manager):**
- zsh with autosuggestions, syntax highlighting, 50k history
- starship prompt
- neovim with treesitter, LSP, telescope
- fzf, zoxide, eza, bat, ripgrep, fd, jq
- git with aliases
- tmux with custom config
- claude-code CLI

**Claude Code:**
- Binary at `/etc/profiles/per-user/claude/bin/claude`
- Skills synced to `~/.claude/skills/`
- Host-specific context at `~/.claude/CLAUDE.md`

## Troubleshooting

**Build fails on remote:**
```bash
ssh claude@<IP> "sudo nixos-rebuild switch --flake /etc/nixos-config#<name> --show-trace"
```

**SSH connection refused after deploy:**
- Wait 30 seconds for services to restart
- Check firewall: `ssh claude@<IP> "sudo iptables -L"`

**Wrong hostname after infect:**
- Hostname updates on next deploy, or reboot after deploy

**Disk space issues:**
```bash
ssh claude@<IP> "sudo nix-collect-garbage -d"
```
