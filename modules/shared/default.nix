{ pkgs, ... }:

{
  # Nix configuration is managed by Determinate Nix
  # nix.* options are disabled when using Determinate with nix.enable = false

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Common environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LANG = "en_US.UTF-8";
  };
}
