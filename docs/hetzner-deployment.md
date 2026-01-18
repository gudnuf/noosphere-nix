# Hetzner Cloud NixOS Deployment

This document summarizes the Hetzner Cloud deployment infrastructure added to this nix-config repository.

## Overview

We created a one-command deployment system for NixOS VMs on Hetzner Cloud using `nixos-anywhere`. Hetzner was chosen because they accept Bitcoin payments (via BitPay).

## What Was Built

### Files Created/Modified

| File | Purpose |
|------|---------|
| `scripts/deploy-hetzner.sh` | Deployment script that creates servers and runs nixos-anywhere |
| `flake.nix` | Added `apps.deploy-hetzner` flake app with bundled dependencies |
| `modules/nixos/network.nix` | DHCP networking for cloud VMs |
| `CLAUDE.hetzner.md` | Host-specific documentation for the hetzner VM |
| `secrets.nix.template` | Added `HCLOUD_TOKEN` placeholder |

### Infrastructure Components

1. **Flake App** (`nix run .#deploy-hetzner`)
   - Bundles `hcloud`, `nixos-anywhere`, and `openssh`
   - Handles server creation, SSH key setup, and NixOS deployment
   - Works from any system (x86_64/aarch64, Linux/macOS)

2. **Network Configuration** (`modules/nixos/network.nix`)
   - Enables DHCP on all common cloud interface names (eth0, eth1, ens0, ens1)
   - IPv6 support enabled
   - DNS fallback to 8.8.8.8 and 1.1.1.1

3. **NixOS Configuration** (`nixosConfigurations.hetzner`)
   - x86_64-linux system
   - disko enabled for declarative disk partitioning
   - Home Manager integration (needs manual activation on first deploy)

## How to Reproduce

### Prerequisites

1. **Hetzner Account** with Bitcoin/crypto payment
   - Sign up at https://accounts.hetzner.com
   - Add payment method (Bitcoin via BitPay available)

2. **API Token**
   - Go to Hetzner Console → Project → Security → API Tokens
   - Create token with Read & Write permissions
   - Add to `secrets.nix`:
     ```nix
     HCLOUD_TOKEN = "your_token_here";
     ```

3. **SSH Key**
   - Ensure `~/.ssh/id_ed25519.pub` exists
   - The deploy script will automatically upload it to Hetzner

### Deployment Commands

```bash
# Export your Hetzner token
export HCLOUD_TOKEN="$(nix eval --raw -f ~/.config/nix-config/secrets.nix HCLOUD_TOKEN)"

# Deploy a new server (creates + installs NixOS)
nix run .#deploy-hetzner -- hetzner --create

# With custom options
nix run .#deploy-hetzner -- hetzner --create --server-type cx23 --location nbg1

# Redeploy to existing server (wipes and reinstalls)
nix run .#deploy-hetzner -- hetzner
```

### Available Server Types

| Type | vCPU | RAM | Disk | Cost |
|------|------|-----|------|------|
| cpx11 | 2 | 2GB | 40GB | ~€5/month |
| cpx21 | 3 | 4GB | 80GB | ~€7/month |
| cx23 | 2 | 4GB | 40GB | ~€4/month |
| cpx31 | 4 | 8GB | 160GB | ~€14/month |

### Available Locations

| Code | Location |
|------|----------|
| fsn1 | Falkenstein, Germany |
| nbg1 | Nuremberg, Germany |
| hel1 | Helsinki, Finland |
| ash | Ashburn, USA |
| hil | Hillsboro, USA |
| sin | Singapore |

**Note:** Not all server types are available in all locations. `cx23` in `nbg1` worked reliably.

## Current Deployment State

### Server Details

```
Hostname:   hetzner
IP Address: 46.224.223.198
Location:   Nuremberg, Germany (nbg1)
Type:       cx23 (2 vCPU, 4GB RAM, 40GB disk)
Cost:       ~€3-4/month
Status:     RUNNING
```

### What's Working

- ✅ NixOS installed and booting
- ✅ Network connectivity (DHCP)
- ✅ SSH access as `claude` user
- ✅ Firewall configured (port 22 open)
- ✅ systemd-boot bootloader

### What Needs Manual Setup

The Home Manager activation didn't complete on first deploy. To fix:

```bash
# SSH into the server
ssh claude@46.224.223.198

# The claude user was created manually, Home Manager needs activation
# This will be fixed in a future nixos-rebuild
```

### Connect to the Server

```bash
ssh claude@46.224.223.198
```

## Lessons Learned

### What Worked

1. **nixos-anywhere** is excellent for remote NixOS deployment
2. **disko** handles disk partitioning declaratively
3. **Hetzner Cloud** has good NixOS compatibility
4. **DHCP networking** with explicit interface names works reliably

### Issues Encountered

1. **Server type availability** - Some types (cx22, cpx21) aren't available in all locations. Use `hcloud server-type list` to check.

2. **Location availability** - fsn1 (Falkenstein) had resource issues. nbg1 (Nuremberg) worked.

3. **Network configuration** - Initial attempts with systemd-networkd and NetworkManager failed. Simple `networking.useDHCP = true` with explicit interface names works.

4. **Home Manager activation** - Didn't activate on first boot. The NixOS user creation via `users.users.claude` works, but Home Manager services need manual trigger.

### Recommended Approach

1. Use `cx23` server type (good balance of resources and cost)
2. Use `nbg1` location (reliable availability)
3. Keep network config simple (just DHCP)
4. After deployment, SSH in and run a rebuild to activate Home Manager

## Managing the Server

### List Servers
```bash
hcloud server list
```

### Server Info
```bash
hcloud server describe hetzner
```

### Delete Server
```bash
hcloud server delete hetzner
```

### Reboot Server
```bash
hcloud server reboot hetzner
```

### Console Access
```bash
hcloud server request-console hetzner
# Returns a WebSocket URL and VNC password
```

## Future Improvements

1. **Fix Home Manager first-boot activation** - Investigate why HM services don't start on initial deploy

2. **Add deploy script for other providers** - The pattern can be adapted for Vultr, DigitalOcean, etc.

3. **Binary cache** - Set up a cache to speed up remote builds

4. **Secrets management** - Consider sops-nix or agenix for secrets on deployed hosts

## Related Files

- `flake.nix` - NixOS configuration definition
- `hosts/nixos/default.nix` - Host-specific settings
- `modules/nixos/` - NixOS modules (network, ssh, firewall, disko)
- `CLAUDE.hetzner.md` - Host-specific context for Claude Code
