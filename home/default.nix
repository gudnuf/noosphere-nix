{ lib, pkgs, inputs, username, ... }:

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

  # Session variables (merge with secrets for shell)
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  } // secrets;

  # Set secrets in launchd environment for GUI apps on macOS
  launchd.agents = lib.mkIf pkgs.stdenv.isDarwin (lib.mapAttrs' (name: value:
    lib.nameValuePair "setenv-${name}" {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.bash}/bin/bash" "-c" "/bin/launchctl setenv ${name} '${value}'" ];
        RunAtLoad = true;
      };
    }
  ) secrets);
}
