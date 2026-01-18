{ ... }:

{
  # Enable networking
  networking.useDHCP = false;

  # Configure all interfaces with DHCP
  # This works for most cloud providers including Hetzner
  networking.interfaces = {
    eth0 = {
      useDHCP = true;
    };
  };

  # DNS configuration (fallback)
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  # Enable systemd-networkd for proper network management
  systemd.network.enable = true;
}
