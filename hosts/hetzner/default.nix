{ lib, pkgs, hostname, username, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/nixos/blog.nix
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

  # =============================================================================
  # SSL / HTTPS Configuration
  # =============================================================================
  # Uncomment and configure once you have a domain pointing to this server.
  #
  # DNS Setup required:
  #   A record: @           -> 77.42.27.244
  #   A record: blog        -> 77.42.27.244
  #   A record: dev         -> 77.42.27.244
  #   (or use a wildcard:  *.yourdomain.com -> 77.42.27.244)
  #
  # services.ssl = {
  #   enable = true;
  #   email = "your-email@example.com";  # For Let's Encrypt notifications
  #   domain = "yourdomain.com";
  # };

  # =============================================================================
  # Blog Service
  # =============================================================================
  services.blog = {
    enable = true;
    port = 3311;
    # Uncomment when SSL is enabled:
    # domain = "blog.yourdomain.com";  # or just "yourdomain.com" for root
  };

  # =============================================================================
  # Development Proxy (port-based routing)
  # =============================================================================
  # Access localhost services via https://dev.yourdomain.com/PORT/path
  # Example: https://dev.yourdomain.com/5173/ -> localhost:5173
  #
  # Uncomment when SSL is enabled:
  # services.devProxy = {
  #   enable = true;
  #   domain = "dev.yourdomain.com";
  #   allowedPorts = [ 3000 3001 4000 5000 5173 8000 8080 8888 ];
  #   # Optional: require password for dev proxy
  #   # basicAuth = {
  #   #   enable = true;
  #   #   htpasswdFile = "/etc/nginx/.htpasswd-dev";
  #   # };
  # };
}
