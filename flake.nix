{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # uConsole (microboi) support
    nixos-raspberrypi.url = "github:robertjakub/nixos-raspberrypi/develop";
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";

    oom-hardware.url = "github:robertjakub/oom-hardware/devel";
    oom-hardware.inputs.nixpkgs.follows = "nixpkgs";
    oom-hardware.inputs.nixos-raspberrypi.follows = "nixos-raspberrypi";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Exposes all flake inputs to our modules...
        # If I understand correctly, that means we don't have to add
        # our modules to the `modules` array below
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/x1/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      # uConsole CM4 (microboi)
      nixosConfigurations.microboi = inputs.nixos-raspberrypi.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          nixos-raspberrypi = inputs.nixos-raspberrypi;
          oom-hardware = inputs.oom-hardware;
        };
        modules = [
          # Hardware modules
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.bluetooth
          inputs.oom-hardware.nixosModules.uc.kernel
          inputs.oom-hardware.nixosModules.uc.configtxt
          inputs.oom-hardware.nixosModules.uc.base-cm4

          # Required compatibility fixes
          ({ lib, modulesPath, ... }: {
            disabledModules = [ (modulesPath + "/rename.nix") ];
            imports = [
              (lib.mkAliasOptionModule [ "environment" "checkConfigurationOptions" ] [ "_module" "check" ])
            ];
            nixpkgs.hostPlatform = "aarch64-linux";
            boot.loader.raspberryPi.bootloader = "kernel";
          })

          ./hosts/microboi/hardware-configuration.nix
          ./hosts/microboi/configuration.nix
        ];
      };
    };
}
