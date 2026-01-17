{ inputs, ... }:

{
  programs.agent-skills = {
    enable = true;

    # Define skill sources
    sources.anthropic = {
      path = inputs.anthropic-skills;
      subdir = "skills";
    };

    # Enable specific skills (or use enableAll = true for all)
    # Available skills can be discovered with: nix run .#skills-list
    skills.enable = [
      "skill-creator"
    ];

    # Uncomment to enable all skills from all sources:
    # skills.enableAll = true;

    # Or enable all from specific source:
    # skills.enableAll = [ "anthropic" ];

    # Target configuration for Claude Code
    targets.claude = {
      dest = ".claude/skills";
      structure = "symlink-tree";
    };
  };
}
