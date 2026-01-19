{ lib, pkgs, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  # Hostname
  networking.hostName = hostname;

  # Bootloader - GRUB for BIOS systems
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Enable zram swap
  zramSwap.enable = true;

  # Clean tmp on boot
  boot.tmp.cleanOnBoot = true;

  # Make passwords declarative (required for hashedPassword to apply)
  users.mutableUsers = false;

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$g.LRzLhlP/KjTUHf$qwRscHCAmKjlR8Le.Xj2uHTh8Ge5/kRx0tggCqwTfX5OckmOoWrKJP4a9kBYIYbpooYSAtNwqsObdFZCrO0Jv/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/nQoOA5iA4VqUH4USn11AnESeR+TWFKmgME6wE2rkC claude@nous"
    ];
  };

  # Root SSH access for deployment
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/nQoOA5iA4VqUH4USn11AnESeR+TWFKmgME6wE2rkC claude@nous"
  ];

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Timezone
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # System state version
  system.stateVersion = "24.11";
}
