{ pkgs, inputs, username, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/skills.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.05";

  # User info
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
