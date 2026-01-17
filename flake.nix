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
              extraSpecialArgs = { inherit inputs username; };
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
      mkNixOSSystem = { system, hostname }: nixpkgs.lib.nixosSystem {
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
              extraSpecialArgs = { inherit inputs username; };
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
    in
    {
      # macOS configuration
      darwinConfigurations = {
        nous = mkDarwinSystem {
          system = "aarch64-darwin";
          hostname = "nous";
        };
      };

      # NixOS configuration (for VM testing)
      nixosConfigurations = {
        nixos-vm = mkNixOSSystem {
          system = "aarch64-linux";
          hostname = "nixos-vm";
        };
      };
    };
}
