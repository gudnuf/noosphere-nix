{ lib, ... }:

{
  # Simple DHCP-based networking for cloud VMs
  networking.useDHCP = lib.mkDefault true;

  # Explicitly enable DHCP for common cloud interface names
  networking.interfaces = {
    eth0.useDHCP = lib.mkDefault true;
    eth1.useDHCP = lib.mkDefault true;
    ens0.useDHCP = lib.mkDefault true;
    ens1.useDHCP = lib.mkDefault true;
  };

  # IPv6 support
  networking.enableIPv6 = true;

  # DNS servers
  networking.nameservers = lib.mkDefault [ "8.8.8.8" "1.1.1.1" ];
}
