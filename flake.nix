{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stable home-manager for xenia (matches nixos-uconsole's nixpkgs 25.11)
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
    };

    # TODO(hypr): try to make this work
    # split-monitor-workspaces = {
    #   url = "github:Duckonaut/split-monitor-workspaces";
    #   inputs.hyprland.follows = "hyprland";
    # };

    # Always up-to-date Claude Code ;)
    claude-code.url = "github:sadjow/claude-code-nix";

    opencode.url = "github:aodhanhayter/opencode-flake";

    # xremap for mouse/keyboard remapping
    xremap.url = "github:xremap/nix-flake";

    # uConsole (xenia) support
    nixos-uconsole.url = "github:nixos-uconsole/nixos-uconsole";

    # Hardware-specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      # Framework 16 AMD (basil)
      nixosConfigurations.basil = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [ (import ./overlays/dfu-programmer.nix) ];
          };
        };
        modules = [
          ./hosts/basil/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      # uConsole CM4 (xenia)
      nixosConfigurations.xenia = inputs.nixos-uconsole.lib.mkUConsoleSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager-stable.nixosModules.default
          ./hosts/xenia/hardware-configuration.nix
          ./hosts/xenia/configuration.nix
        ];
      };

      # ARM64 build server (germain)
      nixosConfigurations.germain = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/germain/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Exposes all flake inputs to our modules...
        # If I understand correctly, that means we don't have to add
        # our modules to the `modules` array below
        specialArgs = {
          inherit inputs;
          # Apply overlays to nixpkgs
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [ (import ./overlays/dfu-programmer.nix) ];
          };
        };
        modules = [
          ./hosts/x1/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
}
