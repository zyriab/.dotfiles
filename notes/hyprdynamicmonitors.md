# HyprDynamicMonitors Setup

A power-aware, event-driven monitor configuration manager for Hyprland.

## Why HyprDynamicMonitors?

- **Native Hyprland syntax** - uses the same monitor config format as hyprland.conf
- **Power awareness** - can adjust settings based on AC/battery
- **Built-in TUI** - interactive terminal UI for visual configuration
- **Event-driven** - listens to Hyprland IPC, near-zero CPU when idle
- **Go templates** - for conditional logic in configs

## Installation (NixOS)

### 1. Add the flake input

In `/etc/nixos/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # ... other inputs

    hyprdynamicmonitors.url = "github:fiffeek/hyprdynamicmonitors";
  };

  outputs = { nixpkgs, hyprdynamicmonitors, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        hyprdynamicmonitors.nixosModules.default
      ];
    };
  };
}
```

### 2. Enable the service

In `/etc/nixos/configuration.nix`:

```nix
{
  services.hyprdynamicmonitors = {
    enable = true;
  };
}
```

### 3. Rebuild and configure

```bash
sudo nixos-rebuild switch
hyprdynamicmonitors tui
```

## Usage

### TUI Configuration

```bash
hyprdynamicmonitors tui
```

The TUI lets you:
- Visually arrange monitors
- Set resolutions and refresh rates
- Save profiles for different setups

### Profiles

Profiles are automatically applied based on:
- Connected monitors
- Power state (AC/battery)
- Lid state (open/closed)

## Resources

- [GitHub Repository](https://github.com/fiffeek/hyprdynamicmonitors)
- [Documentation](https://hyprdynamicmonitors.filipmikina.com)
- [Blog Post](https://filipmikina.com/blog/hyprdynamicmonitors)
