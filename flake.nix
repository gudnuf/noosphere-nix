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
      };
    };
}
