{ ... }:

{
  # Standard GPT layout for cloud VMs
  # Compatible with nixos-anywhere automated deployments
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";  # Common for cloud VMs (virtio)
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
