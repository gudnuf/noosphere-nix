{ lib, pkgs, hostname, username, ... }:

let
  # Only enable VM guest features for local testing VMs
  isLocalVM = hostname == "nixos-vm";
in
{
  config = lib.mkIf isLocalVM {
    # QEMU/UTM guest agent for better integration
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    # Set initial password for test user (change after first login)
    # Password: "test" - ONLY for local VM testing
    users.users.${username}.initialPassword = "test";

    # Allow password authentication for initial setup
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;

    # Virtualisation tweaks for better VM performance
    boot.kernelParams = [ "console=ttyS0" ];

    # Auto-login to console for easier testing
    services.getty.autologinUser = username;

    # Enable virtio for better disk/network performance
    boot.initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"
    ];
  };
}
