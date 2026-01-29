{ pkgs, ... }:

{
  # macOS-specific Nix configuration is managed by Determinate Nix
  # nix.* options are disabled when using Determinate with nix.enable = false

  # System packages available to all users
  # Note: neovim is installed via Home Manager with vim/vi aliases
  environment.systemPackages = with pkgs; [
    curl
    wget
  ];

  # Shells available system-wide
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # Set zsh as a valid login shell
  programs.zsh.enable = true;

  # Fonts (managed by nix-darwin)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

}
