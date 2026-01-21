# CLAUDE.hetzner.md

**Host:** hetzner (NixOS on Hetzner Cloud)
**User:** claude
**Config Location:** Deployed from `~/.config/nix-config` on nous
**System Manager:** NixOS with Home Manager

## Server Details

| Property | Value |
|----------|-------|
| Provider | Hetzner Cloud |
| Server Type | cx23 (2 vCPU, 4GB RAM, 40GB disk) |
| Location | hel1 (Helsinki) |
| IPv4 | 77.42.27.244 |
| IPv6 | 2a01:4f9:c013:57df::1 |
| OS | NixOS 24.11 |

## SSH Access

```bash
ssh claude@77.42.27.244
ssh root@77.42.27.244
```

## Deployment

This server is deployed from the local nix-config on nous (macOS).

### Deploy Configuration

```bash
cd ~/.config/nix-config
nix run .#deploy-hetzner
```

Or manually:

```bash
nixos-rebuild switch \
  --flake ~/.config/nix-config#hetzner \
  --target-host root@77.42.27.244 \
  --build-host root@77.42.27.244 \
  --use-remote-sudo
```

### Check Current Version

```bash
ssh root@77.42.27.244 "nixos-version"
```

## Configuration Files

| What | Location |
|------|----------|
| Host config | `hosts/hetzner/default.nix` |
| Hardware | `hosts/hetzner/hardware-configuration.nix` |
| Networking | `hosts/hetzner/networking.nix` |
| NixOS modules | `modules/nixos/` |
| Home Manager | `home/` |

## Installed Packages

Same as other NixOS hosts - see `modules/nixos/default.nix` and `home/modules/dev-tools.nix`.

## Notes

**Git commit style:** Do NOT add `Co-Authored-By` footers to commit messages. Keep commits clean and simple.

- Server was set up using nixos-infect from Debian 12
- Uses GRUB bootloader (BIOS, not UEFI)
- Static networking configured for Hetzner Cloud
