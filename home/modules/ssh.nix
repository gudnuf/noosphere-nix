{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519_github
        AddKeysToAgent yes

      Host *
        AddKeysToAgent yes
        IdentityAgent ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    '';
  };
}
