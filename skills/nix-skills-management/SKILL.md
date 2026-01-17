# Nix Skills Management

This skill documents how to manage Claude Code skills declaratively using Nix and the `agent-skills-nix` flake.

## Overview

Skills are managed through Home Manager using the `programs.agent-skills` module. The configuration lives in `~/.config/nix-config/home/modules/skills.nix`.

## Configuration Structure

```nix
programs.agent-skills = {
  enable = true;

  # Define where skills come from
  sources.<name> = {
    path = <flake-input-or-path>;
    subdir = "optional/subdirectory";  # if skills aren't at root
  };

  # Select which skills to enable
  skills.enable = [ "skill-name" "another-skill" ];
  # Or enable all: skills.enableAll = true;
  # Or all from specific source: skills.enableAll = [ "source-name" ];

  # Configure where skills are synced
  targets.claude = {
    dest = ".claude/skills";
    structure = "symlink-tree";  # or "link" or "copy-tree"
  };
};
```

## Common Tasks

### Enable an Existing Skill

Edit `~/.config/nix-config/home/modules/skills.nix`:

```nix
skills.enable = [
  "skill-creator"
  "new-skill-to-add"  # Add the skill name here
];
```

Then rebuild:
```bash
darwin-rebuild switch --flake ~/.config/nix-config#nous
# Or use alias: nrs
```

### List Available Skills

Skills are directories containing a `SKILL.md` file. To see what's available from a source:

```bash
# Check anthropic-skills source
ls $(nix flake metadata ~/.config/nix-config --json | jq -r '.locks.nodes["anthropic-skills"].locked.url // empty' 2>/dev/null || echo "Check the flake input path")/skills/

# Or browse the source repo directly
```

### Add a New Skill Source

1. Add the input to `~/.config/nix-config/flake.nix`:

```nix
inputs = {
  # ... existing inputs ...

  my-skills = {
    url = "github:username/skills-repo";
    flake = false;  # Use this for non-flake repos
  };
};
```

2. Add to outputs destructuring:
```nix
outputs = inputs@{ ..., my-skills, ... }:
```

3. Configure the source in `skills.nix`:
```nix
sources.my-skills = {
  path = inputs.my-skills;
  subdir = "skills";  # if skills are in a subdirectory
};
```

4. Enable desired skills:
```nix
skills.enable = [
  "existing-skill"
  "skill-from-my-skills"
];
```

5. Rebuild: `nrs`

### Create a Local Custom Skill

1. Create skill directory:
```bash
mkdir -p ~/.config/nix-config/skills/my-skill-name
```

2. Create `SKILL.md` in that directory with your skill content.

3. Add local source to `skills.nix` (if not already present):
```nix
sources.local = {
  path = ../../skills;  # Relative path from skills.nix
};
```

4. Enable the skill:
```nix
skills.enable = [
  "my-skill-name"
];
```

5. Stage and rebuild:
```bash
git add ~/.config/nix-config/skills/
nrs
```

### Update Skills from Remote Sources

```bash
# Update all flake inputs including skill sources
nix flake update ~/.config/nix-config
# Or use alias: nfu

# Update only a specific skill source
nix flake lock --update-input anthropic-skills ~/.config/nix-config

# Then rebuild to apply
nrs
```

### Disable a Skill

Remove it from the `skills.enable` list and rebuild:

```nix
skills.enable = [
  "skill-creator"
  # "removed-skill"  # Commented out or deleted
];
```

### Enable All Skills

For development or exploration:

```nix
# All skills from all sources
skills.enableAll = true;

# Or all from specific sources only
skills.enableAll = [ "anthropic" "local" ];
```

## Sync Methods

The `structure` option in targets controls how skills are synced:

- **`"symlink-tree"`** (recommended): Uses rsync preserving symlinks, cleans removed skills
- **`"copy-tree"`**: Copies files, dereferences symlinks
- **`"link"`**: Uses Home Manager's `home.file` for individual symlinks

## File Locations

| Purpose | Path |
|---------|------|
| Skills config | `~/.config/nix-config/home/modules/skills.nix` |
| Flake inputs | `~/.config/nix-config/flake.nix` |
| Local skills | `~/.config/nix-config/skills/` |
| Synced skills | `~/.claude/skills/` |

## Troubleshooting

**Skill not appearing after rebuild:**
- Ensure the skill directory contains `SKILL.md`
- Check that new files are staged: `git add skills/`
- Verify the skill name matches the directory name exactly

**Source not found:**
- Ensure the input is added to both `inputs` and the `outputs` function parameters in `flake.nix`
- Run `nix flake check` to validate

**Changes not taking effect:**
- Run `darwin-rebuild switch`, not just `build`
- Check `~/.claude/skills/` to verify sync completed
