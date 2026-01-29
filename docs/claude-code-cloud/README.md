# Claude Code Cloud

A managed service that provisions on-demand NixOS development environments with Claude Code pre-installed, running on Hetzner Cloud.

## What Users Get

- **Instant Dev Environment** - Full NixOS server with Claude Code CLI, zsh, dev tools
- **SSH Access** - Connect as `claude` user with their own SSH key
- **Flexible Compute** - Choose server size based on workload
- **Time-Based Access** - Buy hours, server auto-terminates when expired

## Server Options

| Type | Specs | Hourly | Monthly |
|------|-------|--------|---------|
| cpx11 | 2 vCPU, 2GB RAM, 40GB | ~€0.007 | ~€5 |
| cpx21 | 3 vCPU, 4GB RAM, 80GB | ~€0.010 | ~€7 |
| cpx31 | 4 vCPU, 8GB RAM, 160GB | ~€0.019 | ~€14 |

## Quick Start (Once Implemented)

```bash
# Provision a new instance
ccc provision --ssh-key "ssh-ed25519 AAAA..." --hours 24 --type cpx21

# Check status
ccc status <instance-id>

# Extend time
ccc extend <instance-id> --hours 24

# List all instances
ccc list

# Deprovision
ccc deprovision <instance-id>
```

## Documentation

- [Architecture](./ARCHITECTURE.md) - System design and decisions
- [File Structure](./FILE-STRUCTURE.md) - Files to create and modify
- [Implementation](./IMPLEMENTATION.md) - Phased implementation guide
- [TODO](./TODO.md) - Actionable task list
