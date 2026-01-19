# Hetzner NixOS Deployment Log

## Server Configuration

| Property | Value |
|----------|-------|
| Server Name | `nixos-vm` |
| Server ID | `117782009` |
| Server Type | `cx23` (2 vCPU, 4GB RAM, 40GB disk) |
| Location | `hel1` (Helsinki) |
| IPv4 | `77.42.27.244` |
| IPv6 | `2a01:4f9:c013:57df::1` |
| Initial OS | Debian 12 |
| Final OS | NixOS 24.11 |

## SSH Access

| Property | Value |
|----------|-------|
| SSH Key Name | `claude@nous` |
| SSH Key ID | `105867923` |
| SSH Key Path | `~/.ssh/id_ed25519_github` |
| SSH User | `claude` (root login disabled for security) |
| SSH Command | `ssh claude@77.42.27.244` |

**Note:** Root SSH login is disabled. Use the `claude` user with passwordless sudo.

## User Credentials

| User | Password |
|------|----------|
| claude | `claude2025hetzner` |

Password is set declaratively in `hosts/hetzner/default.nix`. Use for console login or sudo.

## Hetzner API

| Property | Value |
|----------|-------|
| Token Location | `secrets.nix` (HCLOUD_TOKEN) |
| Context | Use `export HCLOUD_TOKEN="..."` before hcloud commands |

## Key Commands Run

### 1. Delete old server
```bash
export HCLOUD_TOKEN="<token>"
hcloud server delete hetzner
```

### 2. Create new worktree (fresh start without nixos-anywhere commits)
```bash
cd ~/.config/nix-config
git worktree add .trees/nixos-infect -b nixos-infect bdbf8ff
```

### 3. Create Debian server
```bash
hcloud server create --name nixos-vm --image debian-12 --type cx23 --ssh-key "claude@nous"
```

### 4. Run nixos-infect
```bash
ssh root@77.42.27.244 "curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.11 bash -x"
```

### 5. Verify NixOS is running
```bash
ssh root@77.42.27.244 "nixos-version"
```

## Deployment Method

Used **nixos-infect** instead of nixos-anywhere:
- Simpler approach that converts an existing Linux installation to NixOS
- Works by installing Nix, building a NixOS system, and switching to it
- Server reboots into NixOS automatically

## Status

- [x] Server created
- [x] nixos-infect completed
- [x] Server rebooted into NixOS
- [ ] Custom NixOS configuration deployed

## Verified NixOS Installation

```
$ ssh root@77.42.27.244 "nixos-version && uname -a"
24.11.719113.50ab793786d9 (Vicuna)
Linux nixos-vm 6.6.94 #1-NixOS SMP PREEMPT_DYNAMIC Thu Jun 19 13:28:47 UTC 2025 x86_64 GNU/Linux
```

## Deploy Custom Configuration

### Quick Deploy

```bash
cd ~/.config/nix-config/.trees/nixos-infect
nix run .#deploy-hetzner
```

### Manual Deploy

```bash
nixos-rebuild switch \
  --flake ~/.config/nix-config/.trees/nixos-infect#hetzner \
  --target-host root@77.42.27.244 \
  --build-host root@77.42.27.244 \
  --use-remote-sudo
```

## Flake Configuration

The flake now includes:
- `nixosConfigurations.hetzner` - NixOS configuration for this server
- `apps.aarch64-darwin.deploy-hetzner` - Deploy script

### Key Files

| File | Purpose |
|------|---------|
| `hosts/hetzner/default.nix` | Host configuration |
| `hosts/hetzner/hardware-configuration.nix` | Hardware/bootloader |
| `hosts/hetzner/networking.nix` | Static IP networking |
| `CLAUDE.hetzner.md` | Host-specific documentation |

## Next Steps

1. ~~Wait for server to reboot~~ ✓
2. ~~Verify NixOS is running~~ ✓
3. ~~Add flake configuration~~ ✓
4. ~~Deploy custom configuration~~ ✓

## Completed Deployment

```
$ ssh claude@77.42.27.244 "nixos-version && hostname"
26.05.20260116.be5afa0 (Yarara)
hetzner
```

The server is now running the full nix-config with:
- Home Manager (zsh, neovim, starship, dev tools)
- SSH hardening (fail2ban, no root login)
- Firewall (only SSH/mosh open)
