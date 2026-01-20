{ pkgs, ... }:

{
  # Nix configuration is managed by Determinate Nix
  # nix.* options are disabled when using Determinate with nix.enable = false

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow insecure packages (trezor-agent depends on python-ecdsa with CVE-2024-23342)
  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
  ];

  # Common environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LANG = "en_US.UTF-8";
  };
}
