# CLAUDE.nixos-vm.md

**Host:** nixos-vm (NixOS)
**User:** claude
**Config Location:** `~/.config/nix-config`
**System Manager:** NixOS + Home Manager

## Status

This is a placeholder file for the NixOS VM configuration. This host is not yet fully configured.

## How You're Running

You (Claude Code) will run on this machine as:
- **Binary:** `claude-code` installed via Nix
- **Shell:** zsh (configured via Home Manager)
- **Skills:** Managed declaratively via `agent-skills-nix` in `home/modules/skills.nix`
  - Skills sync from nix-config to `~/.claude/skills/` on rebuild

## Modifying Global State

All system configuration is declarative via NixOS. To modify this machine:

### 1. Edit Configuration Files

Choose the appropriate file based on what you're changing:

| What to Change | File | Examples |
|----------------|------|----------|
| System packages | `modules/nixos/default.nix` | System-wide packages |
| User CLI tools | `home/modules/dev-tools.nix` | ripgrep, fd, jq, claude-code |
| Shell config | `home/modules/shell.nix` | aliases, zsh settings, starship |
| Git config | `home/modules/git.nix` | git aliases, user settings |
| Skills | `home/modules/skills.nix` | Claude Code skills to enable |
| NixOS settings | `hosts/nixos/default.nix` | System-wide NixOS configuration |
| Secrets/tokens | `secrets.nix` | API keys, credentials (git-ignored) |

### 2. Apply Changes

```bash
nrs  # Alias for: sudo nixos-rebuild switch --flake ~/.config/nix-config#nixos-vm
```

### 3. Rollback (if needed)

```bash
nixos-rebuild --list-generations
sudo /nix/var/nix/profiles/system-N-link/bin/switch-to-configuration switch
```

## System Architecture

### Configuration Layers (Load Order)

1. **Flake** (`flake.nix`) - Defines inputs, outputs, and system builder
2. **Host** (`hosts/nixos/default.nix`) - Hostname, user, system settings
3. **Shared** (`modules/shared/default.nix`) - Cross-platform settings
4. **NixOS** (`modules/nixos/default.nix`) - System packages, services
5. **Home Manager** (`home/default.nix`) - User-level packages and dotfiles

## Notes

**Git commit style:** Do NOT add `Co-Authored-By` footers to commit messages. Keep commits clean and simple.

This file should be updated when the NixOS VM is fully configured.

**Use the `/update-host-context` skill** for guidance on maintaining this host-specific context file.

## Related Files

- `CLAUDE.md` - General nix-config structure and patterns (repo-wide)
- `CLAUDE.nous.md` - macOS host configuration for reference
- `SECRETS.md` - Secrets management documentation
- `skills/update-host-context/SKILL.md` - Skill for maintaining host-specific context
