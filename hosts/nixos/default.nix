{ lib, pkgs, hostname, username, ... }:

let
  # Cloud VMs use disko for filesystem management
  cloudVMs = [ "noosphere" "hetzner" ];
  isCloudVM = builtins.elem hostname cloudVMs;
in
{
  # Hostname
  networking.hostName = hostname;

  # Filesystems (only for local VMs - cloud VMs use disko)
  fileSystems."/" = lib.mkIf (!isCloudVM) {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkIf (!isCloudVM) {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/nQoOA5iA4VqUH4USn11AnESeR+TWFKmgME6wE2rkC claude@nous"
    ];
  };

  # Passwordless sudo for wheel group (needed for remote management)
  security.sudo.wheelNeedsPassword = false;

  # Timezone
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "24.05";
}
