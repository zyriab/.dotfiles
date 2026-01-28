# AGENTS.md

Guide for AI agents working in this NixOS dotfiles repository.

## Repository Overview

This is a **NixOS configuration flake** managing system and home configurations for multiple machines using Nix flakes and home-manager. The repository uses a modular architecture with host-specific configs and reusable modules.

**Primary user:** zyr  
**Shell:** zsh  
**Editor:** neovim (custom Lua config)  
**Desktop:** Hyprland (Wayland compositor)  
**Theme:** GitHub Dark Colorblind (protanopia-friendly) - see `theme.md`

## Hosts

Four machines are configured in this repository:

1. **basil** - Framework 16 AMD (x86_64-linux) - Primary development machine
2. **xenia** - ClockworkPi uConsole CM4 (aarch64-linux) - Portable device with 4G module
3. **x1** - ThinkPad X1 (x86_64-linux)
4. **germain** - ARM64 build server (aarch64-linux) - Hetzner VPS

Each host has:
- `hosts/<hostname>/configuration.nix` - NixOS system config
- `hosts/<hostname>/hardware-configuration.nix` - Hardware-specific settings
- `hosts/<hostname>/home.nix` - Home-manager config for user 'zyr'

## Essential Commands

### Building & Applying Changes

```bash
# Rebuild system configuration (requires sudo)
sudo nixos-rebuild switch --flake .#<hostname>

# Example for basil host
sudo nixos-rebuild switch --flake .#basil

# Test without switching boot entry
sudo nixos-rebuild test --flake .#<hostname>

# Build only (no activation)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Updating Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Show what would be updated
nix flake metadata
```

### Development

```bash
# Check flake syntax
nix flake check

# Show flake outputs
nix flake show

# Enter development shell with nix tools
nix-shell -p <package>

# Format Nix files
nixfmt <file.nix>        # Standard formatter
nixfmt-tree .            # Format entire tree
```

### Git Workflow

```bash
# View changes with delta (configured)
git diff

# Interactive git UI
lazygit
```

## Project Structure

```
.
├── flake.nix              # Main flake definition with inputs/outputs
├── flake.lock             # Locked dependency versions
├── theme.md               # Color scheme documentation (GitHub Dark Colorblind)
├── secrets.nix            # Email addresses (gitignored but checked in - public info)
├── hosts/                 # Per-host configurations
│   ├── basil/            # Framework 16 AMD
│   ├── xenia/            # uConsole CM4
│   ├── x1/               # ThinkPad X1
│   └── germain/          # ARM64 build server
├── modules/
│   ├── home/             # Home-manager modules (user-level)
│   │   ├── desktop.nix   # Hyprshade, blue light filtering
│   │   ├── dev.nix       # Development tools & languages
│   │   ├── git.nix       # Git & lazygit config with delta
│   │   ├── hyprland.nix  # Hyprland WM, hypridle, hyprlock
│   │   ├── neovim.nix    # Neovim wrapper (config in nvim/)
│   │   ├── waybar.nix    # Status bar
│   │   ├── zsh.nix       # Shell config
│   │   ├── ghostty.nix   # Terminal emulator
│   │   ├── fuzzel.nix    # App launcher
│   │   ├── tmux.nix      # Terminal multiplexer
│   │   ├── tools.nix     # CLI utilities
│   │   ├── chromium.nix  # Chromium browser
│   │   ├── zen-browser.nix  # Zen browser (Firefox fork)
│   │   ├── cursor.nix    # Cursor theme (Bibata)
│   │   ├── opencode.nix  # OpenCode AI editor (commented out)
│   │   ├── automount.nix # Auto-mounting
│   │   └── electron-wayland-fixes.nix
│   └── nixos/            # System-level modules
│       ├── apps.nix      # GUI applications (Slack, Spotify, etc.)
│       ├── audio.nix     # Audio/PipeWire
│       ├── browsers.nix  # Browser packages
│       ├── fonts.nix     # Font configuration
│       ├── gaming.nix    # Gaming-related packages
│       ├── gnome.nix     # GNOME components
│       ├── hardware.nix  # Hardware configuration
│       └── security.nix  # Security settings
├── nvim/                 # Neovim configuration (Lua-based)
│   ├── init.lua
│   ├── lua/
│   └── README.md         # Lists supported languages
├── pkgs/                 # Custom package definitions
│   ├── inkdrop.nix       # Inkdrop notes app (custom derivation)
│   └── anthropic-api-key.nix
├── overlays/
│   └── lvm2.nix
└── notes/                # Documentation & project ideas
    ├── hyprdynamicmonitors.md
    ├── hyprmixer-clone.md
    └── waybar-custom-menus.md
```

## Code Organization & Patterns

### Module Pattern

All Nix modules follow this structure:

```nix
{ pkgs, lib, inputs, ... }:
{
  # imports go first
  imports = [ ];
  
  # programs/services configuration
  programs.foo = {
    enable = true;
    # ... settings
  };
  
  # package installations
  home.packages = with pkgs; [
    package1
    package2
  ];
}
```

### Host Configuration Pattern

Each host imports relevant modules and provides special arguments:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/audio.nix
    # ... other modules
  ];
  
  # host-specific settings
  networking.hostName = "hostname";
  system.stateVersion = "25.11";
}
```

### Conditional Compilation

Architecture-specific packages use lib.optionals:

```nix
home.packages = with pkgs; [
  # common packages
  package1
]
++ lib.optionals isX86 [
  # x86-only packages
  postman
  ngrok
];
```

### Shell Scripts in Nix

Custom scripts are written inline using `pkgs.writeShellScript` or `pkgs.writeShellScriptBin`:

```nix
let
  my-script = pkgs.writeShellScript "my-script" ''
    #!/usr/bin/env bash
    # script contents with interpolated ${pkgs.foo} paths
  '';
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "my-command" (builtins.readFile my-script))
  ];
}
```

Example: `modules/home/desktop.nix` implements hyprshade-focus and hyprshade-toggle this way.

## Flake Inputs

Key dependencies (see `flake.nix`):

- **nixpkgs** - Main package repository (nixos-unstable)
- **nixpkgs-kernel** - Pinned to kernel 6.17 (avoiding amdgpu bugs in 6.18+)
- **home-manager** - User environment management
- **home-manager-stable** - Release 25.11 for xenia host
- **xremap** - Keyboard/mouse remapping
- **nixos-uconsole** - uConsole hardware support
- **nixos-hardware** - Hardware-specific configurations
- **zen-browser** - Zen browser flake
- **firefox-addons** - Firefox extensions (for Zen)
- **hyprdynamicmonitors** - Dynamic monitor configuration
- **nur** - Nix User Repository (provides Crush CLI tool)

## Development Tools & Languages

Configured in `modules/home/dev.nix`:

### Languages & Runtimes
- **Go** - programs.go.enable = true
- **Node.js** - nodejs package
- **Lua** - lua + luarocks
- **Rust** - cargo
- **C/C++** - gcc, gnumake

### Formatters & Linters
- **Go:** gofumpt, golines, golangci-lint
- **Lua:** stylua
- **JavaScript/TypeScript:** prettierd
- **Nix:** nixd (LSP), nixfmt, nixfmt-tree

### Neovim Configuration

Custom Lua config in `nvim/` directory. Supports:
- Go (with DAP)
- Templ, htmx, _hyperscript
- SQL
- HTML, CSS, TailwindCSS
- JavaScript/TypeScript (JSDoc + DAP)
- React
- C (basic with DAP)
- Arduino
- Lua

Configuration is symlinked via `xdg.configFile."nvim".source = ../../nvim;`

### IDEs
- **DataGrip** - JetBrains database tool with Wayland fixes and custom UI scale

## Git Configuration

See `modules/home/git.nix`:

- **User:** Arthur Wallendorff
- **Primary email:** howdy@wallenart.dev
- **Work email:** arthur@sponsorcx.com (conditional on `/mnt/data/dev/freelance/sponsor-cx/` directory)
- **Pager:** delta with custom GitHub Dark Colorblind theme
- **Editor:** nvim
- **Default branch:** master
- **Merge conflict style:** diff3
- **Lazygit:** Enabled with delta integration and custom theme

## Theme & Colors

**Theme system:** GitHub Dark Colorblind (protanopia-friendly)

Full documentation in `theme.md`. Key colors:

- **Background:** `#0d1117`
- **Foreground:** `#c9d1d9`
- **Selection:** `#1e4273`
- **Error/Red replacement:** `#ec8e2c` (orange) - **NEVER use red (#ff0000)**
- **Success/Green replacement:** `#58a6ff` (blue) or `#39c5cf` (cyan) - **NEVER use green**
- **Accent:** `#79c0ff` (bright blue)
- **Warning:** `#d29922` (yellow/gold)
- **Neon alerts:** `#ef0fff` (pink for caps lock), `#38d878` (neon green for search)

**Critical:** Do not use red-green color combinations. User has protanopia.

## Hyprland Configuration

Wayland compositor with extensive customization:

- **Lock screen:** hyprlock with fingerprint auth
- **Idle management:** hypridle (dim at 150s, lock at 300s, suspend at 1800s)
- **Blue light filter:** hyprshade with focus-aware toggling (disables for ghostty)
- **Dynamic monitors:** hyprdynamicmonitors (power-aware config)
- **Status bar:** waybar
- **App launcher:** fuzzel
- **Terminal:** ghostty
- **Browser:** Zen (Firefox-based) + Chromium
- **Login manager:** greetd with tuigreet

Custom scripts:
- `hyprshade-toggle` - Cycle between auto/on/off modes
- `hyprshade-focus` - Systemd service that disables blue light filter when ghostty is focused

## Important Gotchas

### 1. Never Edit Generated Files

`hardware-configuration.nix` files are generated by nixos-generate-config. Comment at the top will indicate this. Don't manually edit unless necessary.

### 2. Secrets Management

`secrets.nix` is gitignored but currently checked in (contains only public email addresses). If adding actual secrets, use:
- sops-nix
- agenix
- 1Password integration (already configured for browser)

### 3. Kernel Pinning

basil host uses pinned kernel 6.17 via `pkgs-kernel.linuxPackages_6_17` to avoid amdgpu driver bugs in 6.18+. See flake.nix:

```nix
nixpkgs-kernel.url = "github:nixos/nixpkgs/f6b44b2401525650256b977063dbcf830f762369";
```

### 4. Architecture-Specific Packages

Some packages are x86-only (ngrok, postman). Use conditional compilation:

```nix
let
  isX86 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
  home.packages = lib.optionals isX86 [ pkgs.postman ];
}
```

### 5. Home-Manager Integration

Home-manager is integrated as a NixOS module, not standalone. User config is imported in each host's configuration.nix:

```nix
home-manager = {
  extraSpecialArgs = { inherit inputs; };
  users."zyr" = import ./home.nix;
};
```

### 6. XDG Base Directory

Config files are managed via `xdg.configFile.*`. For example:

```nix
xdg.configFile."hypr/hyprshade.toml".text = ''
  # config contents
'';
```

This creates `~/.config/hypr/hyprshade.toml`.

### 7. Systemd User Services

User services are defined in home-manager modules:

```nix
systemd.user.services.my-service = {
  Unit = { Description = "My service"; };
  Service = { ExecStart = "${pkgs.foo}/bin/foo"; };
  Install = { WantedBy = [ "graphical-session.target" ]; };
};
```

### 8. Electron Wayland Fixes

Some Electron apps need Wayland flags. See `modules/home/electron-wayland-fixes.nix` for the pattern:

```nix
xdg.desktopEntries.app-name = {
  name = "App Name";
  exec = "app-name --enable-features=UseOzonePlatform --ozone-platform=wayland";
};
```

### 9. Nix Experimental Features

Required for flakes: `nix.settings.experimental-features = ["nix-command" "flakes"];`

Already enabled in all host configurations.

### 10. Custom Packages

Custom derivations go in `pkgs/` directory. Example: `inkdrop.nix` shows how to package an Electron app with dpkg source.

Pattern:
```nix
{ stdenv, lib, fetchurl, dpkg, ... }:
stdenv.mkDerivation {
  pname = "app-name";
  version = "1.0.0";
  src = fetchurl { url = "..."; sha256 = "..."; };
  # ... buildInputs, installPhase, etc.
}
```

Import in apps.nix: `(callPackage ../../pkgs/inkdrop.nix { })`

## Testing & Validation

### Before Committing

```bash
# Check flake syntax
nix flake check

# Test build without activation
sudo nixos-rebuild test --flake .#<hostname>

# Verify git status
git status
git diff
```

### After Changes

```bash
# Apply changes
sudo nixos-rebuild switch --flake .#<hostname>

# Check systemd services
systemctl --user status
journalctl --user -xeu <service-name>

# Restart user services if needed
systemctl --user restart graphical-session.target
```

## Common Tasks

### Adding a New Package

1. For system-wide GUI app: Add to `modules/nixos/apps.nix`
2. For user CLI tool: Add to `modules/home/tools.nix` or `modules/home/dev.nix`
3. For home packages: Add to `home.packages` in relevant home module

```nix
# In modules/home/tools.nix
home.packages = with pkgs; [
  existing-package
  new-package  # Add here
];
```

### Adding a New Home Module

1. Create `modules/home/my-module.nix`
2. Import in host's `home.nix`:
   ```nix
   imports = [
     ../../modules/home/my-module.nix
   ];
   ```

### Configuring a New Application

Use `xdg.configFile` for config files or `programs.<app>` for built-in home-manager support:

```nix
# Option 1: xdg.configFile
xdg.configFile."app/config.toml".text = ''
  key = "value"
'';

# Option 2: programs module (if available)
programs.app = {
  enable = true;
  settings = {
    key = "value";
  };
};
```

### Adding a Systemd Service

```nix
systemd.user.services.my-service = {
  Unit = {
    Description = "My custom service";
    After = [ "graphical-session.target" ];
    PartOf = [ "graphical-session.target" ];
  };
  Service = {
    Type = "simple";
    ExecStart = "${pkgs.my-package}/bin/my-command";
    Restart = "on-failure";
    RestartSec = 5;
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

### Updating Flake Inputs

```bash
# Update all inputs
nix flake update

# Or update specific input
nix flake lock --update-input nixpkgs

# Commit the updated flake.lock
git add flake.lock
git commit -m "chore: update flake inputs"
```

### Creating a New Host

1. Generate hardware config:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```

2. Create `hosts/<hostname>/configuration.nix` (copy from existing host)

3. Create `hosts/<hostname>/home.nix` (copy from existing host)

4. Add to flake.nix outputs:
   ```nix
   nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";  # or aarch64-linux
     specialArgs = { inherit inputs; };
     modules = [
       ./hosts/<hostname>/configuration.nix
       inputs.home-manager.nixosModules.default
     ];
   };
   ```

## Notes Directory

`notes/` contains project ideas and documentation:

- **hyprdynamicmonitors.md** - Setup guide for power-aware monitor config
- **hyprmixer-clone.md** - Plan for reimplementing volume/media control
- **waybar-custom-menus.md** - Custom waybar modules design

These are reference documents, not active configuration.

## Debugging

### Service Issues

```bash
# Check user service status
systemctl --user status <service-name>

# View logs
journalctl --user -xeu <service-name>

# Restart service
systemctl --user restart <service-name>

# Reload systemd user daemon
systemctl --user daemon-reload
```

### Hyprland Issues

```bash
# Check Hyprland logs
journalctl --user -xeu hyprland.service

# Reload Hyprland config
hyprctl reload

# List monitors
hyprctl monitors
```

### Nix Build Issues

```bash
# Show detailed build output
nixos-rebuild switch --flake .#<hostname> --show-trace

# Check for evaluation errors
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Build with verbose output
nix build --verbose .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

## File Naming & Conventions

- **Module files:** kebab-case.nix (e.g., `zen-browser.nix`)
- **Host names:** lowercase (basil, xenia, x1, germain)
- **Git branches:** Default branch is `master` (not main)
- **Commit style:** Conventional commits encouraged but not enforced
- **Comments:** Use `# TODO:` for future work, `# NOTE:` for important context
- **Indentation:** 2 spaces (Nix standard)

## Browser & Extensions

### Zen Browser

Primary browser (Firefox-based). Configured in:
- System: `modules/nixos/browsers.nix`
- Home: `modules/home/zen-browser.nix`

Extensions managed via firefox-addons input.

### Chromium

Secondary browser for compatibility. Configured in `modules/home/chromium.nix`.

### 1Password Integration

Custom allowed browsers configured in `/etc/1password/custom_allowed_browsers`:
- zen
- chromium

## CI/CD

No CI/CD currently configured. Manual workflow:
1. Make changes
2. Test with `nixos-rebuild test`
3. Apply with `nixos-rebuild switch`
4. Commit to git

## Additional Resources

- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Home-Manager Manual: https://nix-community.github.io/home-manager/
- Hyprland Wiki: https://wiki.hyprland.org/
- Theme reference: `theme.md` in repository root

## Questions to Ask Yourself

Before making changes:

1. Is this a system-level change (nixos module) or user-level (home module)?
2. Does this need to be host-specific or can it be shared?
3. Are there architecture-specific considerations (x86 vs ARM)?
4. Does this affect the theme/colors? Check `theme.md` for consistency.
5. Will this change require a system rebuild or just home-manager?
6. Are there any security implications? (secrets, permissions, etc.)
7. Should this be conditional on power state or monitor config?

## When in Doubt

1. Check existing modules for similar patterns
2. Search nixpkgs: `nix-search-cli <package>`
3. Read the module source in nixpkgs: https://github.com/NixOS/nixpkgs
4. Check home-manager options: https://nix-community.github.io/home-manager/options.xhtml
5. Review git history: `git log --all --oneline -- <file>`
6. Ask user for clarification rather than guessing

## Protanopia Accessibility Notes

**Critical for all visual changes:**

- Never use red for errors - use orange (#ec8e2c)
- Never use green for success - use blue (#58a6ff) or cyan (#39c5cf)
- No red-green color combinations ever
- High contrast is preferred (check against #0d1117 background)
- Use shapes/icons in addition to colors when possible
- Neon colors (#ef0fff, #38d878) reserved for critical alerts only

This applies to:
- Terminal color schemes
- Waybar modules
- Hyprlock colors
- Any custom scripts with colored output
- Notification styling
- All UI elements

---

**Last updated:** 2025-01-28  
**Agent:** If you find gaps in this documentation, update this file.
