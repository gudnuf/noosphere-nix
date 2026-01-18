{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowTcpForwarding = true;
      AllowAgentForwarding = true;
      ClientAliveInterval = 60;
      ClientAliveCountMax = 3;
    };
    extraConfig = "AllowUsers claude";
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
  };
}
