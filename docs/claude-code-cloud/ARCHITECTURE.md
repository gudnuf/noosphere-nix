# Architecture

## Overview

CLI-first architecture that builds on existing noosphere-nix patterns:

```
┌─────────────────────────────────────────────────────────┐
│                    Operator Machine                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ ccc CLI     │→ │ provision.sh│→ │ state/          │  │
│  │             │  │ deprovision │  │ instances.json  │  │
│  └─────────────┘  └──────┬──────┘  └─────────────────┘  │
└──────────────────────────┼──────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   Hetzner Cloud API    │
              │   (via hcloud CLI)     │
              └───────────┬────────────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
      ┌──────────┐  ┌──────────┐  ┌──────────┐
      │ cc-abc123│  │ cc-def456│  │ cc-ghi789│
      │ (user 1) │  │ (user 2) │  │ (user 3) │
      └──────────┘  └──────────┘  └──────────┘
         NixOS instances with Claude Code
```

## Key Design Decisions

### 1. Dynamic Configuration via Nix Modules

Instead of generating new host configs per user, use Nix's module system to parameterize a single configuration. User SSH keys and instance IDs are passed at build time.

**Why:** Avoids git repo bloat, cleaner than static configs per user, leverages Nix's strengths.

### 2. DHCP Networking

Use DHCP instead of static IPs. Hetzner assigns IPs automatically.

**Why:** Removes need to manage IP allocation, simpler provisioning, works out of the box.

### 3. Service-Owned Hetzner Account

The service operator owns the Hetzner account and provisions servers for users. Users only provide their SSH public key.

**Why:** Better UX (users don't need Hetzner accounts), enables billing, centralized management.

### 4. Pre-paid Time Blocks

Simple model: users pay for X hours, get a server. Automatic cleanup when time expires.

**Why:** Simple to implement, clear expectations, prevents abandoned servers.

### 5. User-Configurable Server Types

Users choose their server size at provisioning time:
- `cpx11` - 2 vCPU, 2GB RAM, 40GB disk
- `cpx21` - 3 vCPU, 4GB RAM, 80GB disk (default)
- `cpx31` - 4 vCPU, 8GB RAM, 160GB disk

**Why:** Different workloads need different resources, cost flexibility.

## Security Model

| Aspect | Approach |
|--------|----------|
| User Isolation | Each user gets their own server (no multi-tenancy) |
| SSH Keys | Only accept ed25519 or RSA-4096+ |
| API Token | HCLOUD_TOKEN in operator environment only |
| Cleanup | Automatic expiration prevents abandoned servers |
| Firewall | SSH only (port 22) by default |

## State Management

Simple JSON-based state tracking in `state/instances.json`:

```json
{
  "instances": {
    "abc123": {
      "instanceId": "abc123",
      "email": "user@example.com",
      "serverName": "cc-abc123",
      "serverIp": "65.108.x.x",
      "serverType": "cpx21",
      "createdAt": "2026-01-21T10:00:00Z",
      "expiresAt": "2026-01-22T10:00:00Z",
      "status": "running"
    }
  }
}
```

**Why JSON:** Human-readable, easy to debug, no database dependency, can migrate to DB later.

## Deployment Flow

```
1. User Request
   └→ Email + SSH key + hours + server type

2. provision.sh
   ├→ Generate instance ID (random hex)
   ├→ Create Hetzner server (hcloud create)
   ├→ Wait for SSH availability
   ├→ Build NixOS config with user's SSH key
   ├→ Deploy via nixos-anywhere
   ├→ Update state file
   └→ Return: IP address, instance ID, expiration time

3. User Access
   └→ ssh claude@<ip>

4. Expiration (cron job)
   ├→ Check instances.json for expired
   ├→ Delete Hetzner server
   └→ Update state file
```
