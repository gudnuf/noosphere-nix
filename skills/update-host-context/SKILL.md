# Update Host Context Skill

Maintains host-specific CLAUDE.md files that provide machine-specific context for Claude Code across different systems.

## System Architecture

This nix-config uses a two-tier CLAUDE.md documentation system:

1. **Repository-level** (`CLAUDE.md`) - Documents overall nix-config structure, patterns, and cross-host conventions
2. **Host-level** (`CLAUDE.{hostname}.md`) - Documents each machine's specific configuration, packages, and workflows

Each host automatically gets its own context via Nix:
```
CLAUDE.{hostname}.md → (Nix rebuild) → ~/.claude/CLAUDE.md (symlink)
```

## Current Hosts

| Hostname | File | Platform | Status |
|----------|------|----------|--------|
| nous | `CLAUDE.nous.md` | macOS (Darwin) | Fully documented |
| nixos-vm | `CLAUDE.nixos-vm.md` | NixOS (aarch64) | Placeholder |
| noosphere | `CLAUDE.noosphere.md` | NixOS cloud (x86_64) | Placeholder |
| mynymbox | `CLAUDE.mynymbox.md` | NixOS cloud (x86_64) | Placeholder |

## When to Update

### Update CLAUDE.md (repo-level) when:
- File structure changes
- New configuration patterns are established
- Cross-host conventions change
- Skills management system changes
- New hosts are added

### Update CLAUDE.{hostname}.md (host-level) when:
- Packages are added/removed on that host
- Configuration modules change for that host
- Workflows specific to that host evolve
- Tools or aliases change
- macOS defaults change (Darwin hosts)
- System services change (NixOS hosts)

## How to Update Host-Specific Files

### 1. Manual Update

When you make significant configuration changes:

```bash
# 1. Make your nix config changes
vim home/modules/dev-tools.nix  # Example: add packages

# 2. Update the corresponding CLAUDE.{hostname}.md
vim CLAUDE.nous.md              # Document the changes

# 3. Rebuild to test
nrs

# 4. Commit together
git add .
git commit -m "add: new packages and update host context"
```

### 2. Using update-context Skill

For maintaining CLAUDE.md files using AI assistance:

```bash
# Full analysis and update proposal
/update-context

# Targeted update for specific content
# Ask: "Update CLAUDE.nous.md to document the new tmux configuration"
```

The `update-context` skill follows standards for maintaining lean, accurate context files. Use it for repository-level `CLAUDE.md` updates.

### 3. Proactive Updates

When Claude (you!) makes changes to the nix configuration during a session:

**Best Practice:**
1. After modifying nix files, immediately update the relevant CLAUDE.{hostname}.md
2. Document what changed and why in the host context
3. Keep host context in sync with actual configuration

**Example:**
```
User: "Add ripgrep to my system"
Claude:
  1. Adds ripgrep to home/modules/dev-tools.nix
  2. Updates CLAUDE.nous.md to list ripgrep in installed packages
  3. Commits both changes together
```

## Adding a New Host

To add a new host to the system:

### 1. Create the host's CLAUDE.md file

```bash
# Copy existing template
cp CLAUDE.nixos-vm.md CLAUDE.new-hostname.md

# Edit to document the new host
vim CLAUDE.new-hostname.md
```

Update these sections:
- Host/User/Platform information
- Installed packages specific to that host
- Host-specific configurations
- Any unique workflows

### 2. Add host to flake.nix

```nix
# For Darwin hosts
darwinConfigurations = {
  new-hostname = mkDarwinSystem {
    system = "aarch64-darwin";  # or x86_64-darwin
    hostname = "new-hostname";
  };
};

# For NixOS hosts
nixosConfigurations = {
  new-hostname = mkNixOSSystem {
    system = "x86_64-linux";    # or aarch64-linux
    hostname = "new-hostname";
    enableDisko = true;         # if using disko
  };
};
```

### 3. Stage and rebuild

```bash
# Stage the new CLAUDE file (required for flakes to see it)
git add CLAUDE.new-hostname.md

# Check for errors
nfc

# On the new host, rebuild
sudo darwin-rebuild switch --flake ~/.config/nix-config#new-hostname
# or
sudo nixos-rebuild switch --flake ~/.config/nix-config#new-hostname
```

### 4. Verify symlink

```bash
ls -la ~/.claude/CLAUDE.md
# Should point to CLAUDE.new-hostname.md via Nix store

head ~/.claude/CLAUDE.md
# Should show the new host's context
```

## File Template

When creating a new host's CLAUDE.md, include these sections:

```markdown
# CLAUDE.{hostname}.md

**Host:** {hostname} ({Platform})
**User:** {username}
**Config Location:** `~/.config/nix-config`
**System Manager:** {nix-darwin|NixOS} + Home Manager

## How You're Running
- Binary location and installation method
- Shell configuration
- Skills management setup

## Modifying Global State
- Table of what to change and where
- Rebuild command
- Rollback procedure

## System Architecture
- Configuration layers
- Critical constraints

## Installed Packages
- System packages
- User CLI tools
- GUI applications (if applicable)

## Shell Environment
- Key aliases
- Tools and integrations

## Common Workflows
- Adding packages
- Updating packages
- Testing and rollback

## How to Update This File
Reference to /update-host-context skill

## Related Files
- Links to CLAUDE.md, SECRETS.md, etc.
```

## Workflow Integration

### During Development

When working on this nix-config, always keep CLAUDE.md files in sync:

1. **Before making changes**: Read the relevant CLAUDE.{hostname}.md to understand current state
2. **While making changes**: Note what needs to be documented
3. **After making changes**: Update CLAUDE.{hostname}.md immediately
4. **Before committing**: Ensure CLAUDE.md changes are included in the commit

### During Deployment

When deploying to a new host:

1. Create CLAUDE.{hostname}.md before deploying
2. Document the intended configuration
3. Deploy and verify
4. Update CLAUDE.{hostname}.md with any adjustments made during deployment

## Best Practices

### Keep It Current
- Update CLAUDE.md files in the same commit as config changes
- Don't let documentation drift from reality
- Review during each rebuild

### Keep It Concise
- Document what's different about this host
- Don't duplicate information from CLAUDE.md (repo-level)
- Focus on actionable information

### Keep It Accurate
- Verify package lists match actual configuration
- Test commands before documenting them
- Update when you discover errors

### Keep It Useful
- Write for "future you" who forgot the setup
- Include troubleshooting for common issues
- Document the "why" not just the "what"

## Troubleshooting

### CLAUDE.md symlink not created

**Problem:** After rebuild, `~/.claude/CLAUDE.md` doesn't exist

**Solution:**
1. Check if CLAUDE.{hostname}.md is staged: `git status`
2. Check flake evaluation: `nfc`
3. Check home-manager activation logs during rebuild

### Wrong CLAUDE.md content

**Problem:** `~/.claude/CLAUDE.md` shows wrong host's content

**Solution:**
1. Verify hostname: `hostname`
2. Check flake.nix has correct hostname mapping
3. Verify home/default.nix symlink logic: `home.file.".claude/CLAUDE.md".source = ../CLAUDE.${hostname}.md;`

### Changes not reflected after rebuild

**Problem:** Updated CLAUDE.{hostname}.md but changes don't show

**Solution:**
1. Ensure file is staged with git: `git add CLAUDE.{hostname}.md`
2. Rebuild: `nrs`
3. Check symlink: `ls -la ~/.claude/CLAUDE.md`
4. Read file: `head ~/.claude/CLAUDE.md`

## Related Skills

- **update-context**: For maintaining repository-level CLAUDE.md
- **nix-skills-management**: For managing Claude Code skills via Nix
- **skill-creator**: For creating new skills

## Examples

### Example 1: Adding a package

```bash
# 1. Add package to config
echo '  jq' >> home/modules/dev-tools.nix

# 2. Update host context immediately
vim CLAUDE.nous.md  # Add jq to "Installed Packages" section

# 3. Rebuild
nrs

# 4. Commit together
git add home/modules/dev-tools.nix CLAUDE.nous.md
git commit -m "add: jq for JSON processing"
```

### Example 2: New macOS default

```bash
# 1. Add setting to Darwin config
vim hosts/darwin/default.nix
# Added: dock.tilesize = 36;

# 2. Document in host context
vim CLAUDE.nous.md
# Under "macOS Defaults" → Dock: add tilesize documentation

# 3. Rebuild and commit
nrs
git add hosts/darwin/default.nix CLAUDE.nous.md
git commit -m "update: reduce dock icon size to 36px"
```

### Example 3: New cloud VM

```bash
# 1. Create host context
cp CLAUDE.noosphere.md CLAUDE.newserver.md
vim CLAUDE.newserver.md  # Customize for new server

# 2. Add to flake
vim flake.nix
# Added newserver to nixosConfigurations

# 3. Stage and check
git add CLAUDE.newserver.md flake.nix
nfc

# 4. Deploy to new server
# (on the new server)
sudo nixos-rebuild switch --flake ~/.config/nix-config#newserver

# 5. Verify
ls -la ~/.claude/CLAUDE.md
```

## Summary

The host-specific CLAUDE.md system ensures Claude always knows:
- What machine it's running on
- How to modify that machine's state
- What tools and packages are available
- Host-specific workflows and patterns

Keep CLAUDE.{hostname}.md files accurate and current for the best Claude Code experience across all your systems.
