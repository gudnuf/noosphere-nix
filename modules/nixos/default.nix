{ pkgs, ... }:

{
  imports = [
    ./network.nix
    ./ssh.nix
    ./mosh.nix
    ./firewall.nix
    ./vm-guest.nix
  ];
  # NixOS-specific Nix configuration
  nix = {
    # NixOS-specific GC timing
    gc.dates = "weekly";

    # Enable flakes and new nix commands
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # System packages available to all users
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
  ];

  # Shells
  programs.zsh.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
