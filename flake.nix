{
  description = "Nix configuration for nous";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, claude-code, agent-skills, anthropic-skills, ... }:
    let
      username = "claude";

      # Helper to create darwin systems
      mkDarwinSystem = { system, hostname }: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./hosts/darwin
          ./modules/shared
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ claude-code.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username hostname; };
              users.${username} = {
                imports = [
                  (import ./home)
                  agent-skills.homeManagerModules.default
                ];
              };
            };
          }
        ];
      };

      # Helper to create NixOS systems
      mkNixOSSystem = { system, hostname, enableDisko ? false }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./hosts/nixos
          ./modules/shared
          ./modules/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username hostname; };
              users.${username} = {
                imports = [
                  (import ./home)
                  agent-skills.homeManagerModules.default
                ];
              };
            };
          }
        ] ++ (if enableDisko then [
          inputs.disko.nixosModules.disko
          ./modules/nixos/disko.nix
        ] else []);
      };

      # Helper to create Hetzner cloud systems
      mkHetznerSystem = { hostname, targetHost }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./hosts/hetzner
          ./modules/shared
          ./modules/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username hostname; };
              users.${username} = {
                imports = [
                  (import ./home)
                  agent-skills.homeManagerModules.default
                ];
              };
            };
          }
        ];
      };

      # Package sets for apps
      pkgsX86 = import nixpkgs { system = "x86_64-linux"; };
      pkgsDarwin = import nixpkgs { system = "aarch64-darwin"; };
    in
    {
      # macOS configuration
      darwinConfigurations = {
        nous = mkDarwinSystem {
          system = "aarch64-darwin";
          hostname = "nous";
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        # Local VM testing (aarch64)
        nixos-vm = mkNixOSSystem {
          system = "aarch64-linux";
          hostname = "nixos-vm";
        };
        # Cloud VMs (x86_64)
        noosphere = mkNixOSSystem {
          system = "x86_64-linux";
          hostname = "noosphere";
          enableDisko = true;
        };
        mynymbox = mkNixOSSystem {
          system = "x86_64-linux";
          hostname = "mynymbox";
          enableDisko = true;
        };
        # Hetzner Cloud
        hetzner = mkHetznerSystem {
          hostname = "hetzner";
          targetHost = "77.42.27.244";
        };
      };

      # Deploy apps
      apps.aarch64-darwin.deploy-hetzner = {
        type = "app";
        program = toString (pkgsDarwin.writeShellScript "deploy-hetzner" ''
          set -euo pipefail

          TARGET_IP="77.42.27.244"
          TARGET_USER="claude"
          TARGET_HOST="$TARGET_USER@$TARGET_IP"
          FLAKE_DIR="''${FLAKE_DIR:-$(pwd)}"

          echo "Deploying NixOS configuration to Hetzner server..."
          echo "Target: $TARGET_HOST"
          echo "Flake: $FLAKE_DIR#hetzner"
          echo ""

          # Copy flake to remote and build there
          echo "Step 1: Copying flake to remote server..."
          ${pkgsDarwin.rsync}/bin/rsync -avz --delete \
            --exclude='.git' \
            --exclude='.trees' \
            --exclude='result' \
            -e "ssh -o StrictHostKeyChecking=no" \
            "$FLAKE_DIR/" "$TARGET_HOST:/tmp/nixos-config/"

          echo ""
          echo "Step 2: Building and switching on remote (via sudo)..."
          ssh -o StrictHostKeyChecking=no "$TARGET_HOST" \
            "sudo cp -r /tmp/nixos-config /etc/nixos-config && sudo chown -R root:root /etc/nixos-config && sudo nixos-rebuild switch --flake /etc/nixos-config#hetzner"

          echo ""
          echo "Deployment complete!"
          echo "NixOS version:"
          ssh -o StrictHostKeyChecking=no "$TARGET_HOST" "nixos-version"
        '');
      };
    };
}
