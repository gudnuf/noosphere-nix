{ pkgs, inputs, username, ... }:

let
  # Import secrets if the file exists, otherwise use empty set
  secretsPath = ../secrets.nix;
  secrets = if builtins.pathExists secretsPath
    then import secretsPath
    else {};
in
{
  imports = [
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/dev-tools.nix
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

  # Session variables (merge with secrets)
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  } // secrets;
}
