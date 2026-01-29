# File Structure

## New Files to Create

```
noosphere-nix/
├── hosts/
│   └── cloud-instance/           # NEW: Cloud instance host config
│       ├── default.nix           # Minimal host config
│       ├── hardware-configuration.nix  # QEMU/KVM config
│       └── networking.nix        # DHCP networking
│
├── modules/
│   └── nixos/
│       └── cloud-instance.nix    # NEW: Parameterized module
│
├── scripts/
│   └── cloud/                    # NEW: Cloud provisioning scripts
│       ├── provision.sh          # Main provisioning script
│       ├── deprovision.sh        # Server teardown
│       ├── check-expired.sh      # Cron job for cleanup
│       ├── extend.sh             # Extend instance time
│       ├── status.sh             # Check instance status
│       ├── ccc                   # CLI wrapper
│       └── lib/
│           └── state.sh          # State management helpers
│
├── state/                        # NEW: Runtime state (git-ignored)
│   ├── .gitkeep
│   └── instances.json            # Instance tracking
│
├── CLAUDE.cloud-instance.md      # NEW: Host context for cloud instances
└── docs/
    └── claude-code-cloud/        # NEW: Service documentation
        ├── README.md
        ├── ARCHITECTURE.md
        ├── FILE-STRUCTURE.md
        ├── IMPLEMENTATION.md
        └── TODO.md
```

## Files to Modify

### `flake.nix`

Add `mkCloudInstance` helper and cloud-instance configuration:

```nix
# Add to let block
mkCloudInstance = { instanceId, userSshKey }: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs username;
    hostname = "cc-${instanceId}";
  };
  modules = [
    ./hosts/cloud-instance
    ./modules/shared
    ./modules/nixos
    ./modules/nixos/cloud-instance.nix
    {
      services.cloudInstance = {
        enable = true;
        inherit instanceId userSshKey;
      };
    }
    home-manager.nixosModules.home-manager
    { /* home-manager config */ }
  ];
};

# Add to nixosConfigurations
cloud-instance = mkCloudInstance {
  instanceId = "template";
  userSshKey = "ssh-ed25519 PLACEHOLDER";
};
```

### `.gitignore`

Add:
```
state/instances.json
state/billing.json
```

---

## File Details

### `modules/nixos/cloud-instance.nix`

Parameterized NixOS module:

```nix
{ lib, config, ... }:
with lib;
let
  cfg = config.services.cloudInstance;
in {
  options.services.cloudInstance = {
    enable = mkEnableOption "Cloud instance configuration";

    userSshKey = mkOption {
      type = types.str;
      description = "User's SSH public key";
    };

    instanceId = mkOption {
      type = types.str;
      description = "Unique instance identifier";
    };

    expiresAt = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "ISO timestamp when instance expires";
    };
  };

  config = mkIf cfg.enable {
    # Inject user's SSH key
    users.users.claude.openssh.authorizedKeys.keys = [ cfg.userSshKey ];

    # Instance metadata
    environment.etc."cloud-instance/id".text = cfg.instanceId;
    environment.etc."cloud-instance/expires".text = cfg.expiresAt or "never";
  };
}
```

### `hosts/cloud-instance/default.nix`

Minimal host configuration:

```nix
{ lib, pkgs, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/nixos/cloud-instance.nix
  ];

  networking.hostName = hostname;

  # GRUB for BIOS systems
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    # SSH key injected by cloud-instance module
  };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";
}
```

### `hosts/cloud-instance/networking.nix`

DHCP-based networking (simpler than static):

```nix
{ ... }:

{
  networking = {
    useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
}
```

### `scripts/cloud/provision.sh`

See IMPLEMENTATION.md for full script.

### `state/instances.json`

Runtime state (git-ignored):

```json
{
  "instances": {}
}
```
