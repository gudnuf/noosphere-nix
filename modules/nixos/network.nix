{ lib, ... }:

{
  # Use systemd-networkd
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Match all ethernet interfaces and enable DHCP
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en* eth*";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # IPv6 support
  networking.enableIPv6 = true;

  # DNS servers as fallback
  networking.nameservers = lib.mkDefault [ "8.8.8.8" "1.1.1.1" ];
}
