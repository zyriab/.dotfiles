{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Always up-to-date Claude Code ;)
    claude-code.url = "github:sadjow/claude-code-nix";

    opencode.url = "github:aodhanhayter/opencode-flake";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/x1/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
}
