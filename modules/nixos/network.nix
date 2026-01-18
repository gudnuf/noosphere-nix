{ config, lib, ... }:

{
  # Enable automatic DHCP on all interfaces
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces = { };

  # Enable networking
  networking.enableIPv6 = true;

  # Standard cloud DNS
  networking.nameservers = lib.mkDefault [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
}
