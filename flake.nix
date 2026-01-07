{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    # Pinned nixpkgs for kernel 6.17 (avoiding amdgpu bugs in 6.18+)
    nixpkgs-kernel.url = "github:nixos/nixpkgs/f6b44b2401525650256b977063dbcf830f762369";

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

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Firefox addons (for Zen extensions)
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dynamic monitor configuration for Hyprland
    hyprdynamicmonitors.url = "github:fiffeek/hyprdynamicmonitors";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      # Framework 16 AMD (basil)
      nixosConfigurations.basil =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-kernel = import inputs.nixpkgs-kernel { inherit system; };
            firefox-addons = pkgs.callPackage inputs.firefox-addons { };
          };
          modules = [
            ./hosts/basil/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.nur.modules.nixos.default
            { nixpkgs.config.allowUnfree = true; }
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
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/x1/configuration.nix
          inputs.home-manager.nixosModules.default
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
}
