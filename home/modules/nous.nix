{ pkgs, ... }:

{
  programs.nous = {
    enable = true;
    hooks.enable = false;  # Managed manually in ~/.claude/settings.json
    keybindings.enable = true;
    shellAliases = true;
  };
}
