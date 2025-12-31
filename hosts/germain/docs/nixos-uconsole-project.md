# NixOS uConsole Project

Making NixOS a realistic option for uConsole users.

## Vision

- **Flash and go**: Users download an image, flash it, boot, done
- **Cached builds**: No 7-hour kernel compilation
- **Multiple flavors**: Minimal, Hyprland, touch-friendly desktop
- **Great docs**: Clear guides for customization

## Project Components

### 1. Infrastructure

```
nixos-uconsole/
├── flake.nix              # Main flake
├── modules/
│   ├── base.nix           # Common: NetworkManager, SSH, utils
│   ├── hyprland.nix       # Hyprland + Waybar config
│   └── gnome-touch.nix    # Touch-friendly Gnome variant
├── images/
│   ├── minimal.nix        # Just boot + network + SSH
│   ├── hyprland.nix       # Tiling WM setup
│   └── gnome-touch.nix    # Touch-optimized desktop
└── docs/
    ├── building.md        # How to build from scratch
    ├── configuration.md   # Post-install customization
    └── contributing.md    # How to help
```

### 2. Cachix Setup

```bash
# One-time setup
cachix create nixos-uconsole
# Get signing key, add to GitHub secrets

# After each build
cachix push nixos-uconsole ./result
```

### 3. GitHub Actions Automation

```yaml
# .github/workflows/build.yml
name: Build uConsole Images

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  push:
    branches: [main]
  workflow_dispatch:  # Manual trigger

jobs:
  build:
    runs-on: ubuntu-latest  # Or self-hosted ARM runner
    steps:
      - uses: actions/checkout@v4

      - uses: cachix/install-nix-action@v27
        with:
          extra_nix_config: |
            extra-platforms = aarch64-linux

      - uses: cachix/cachix-action@v15
        with:
          name: nixos-uconsole
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'

      # Enable QEMU for ARM builds (slow but works)
      - uses: docker/setup-qemu-action@v3

      - name: Build minimal image
        run: nix build .#images.minimal

      - name: Push to Cachix
        run: cachix push nixos-uconsole ./result

      - name: Upload image as artifact
        uses: actions/upload-artifact@v4
        with:
          name: nixos-uconsole-minimal
          path: result/sd-image/*.img
```

**Better option**: Self-hosted runner on germain (ARM64 native = fast)

### 4. Image Distribution

- GitHub Releases for images
- Cachix for package cache
- Optional: nixos-uconsole.org pointing to GitHub Pages

## Base Image Spec

What the minimal image should include:

```nix
# Enabled by default
networking.networkmanager.enable = true;  # Auto-starts!
services.openssh.enable = true;           # Auto-starts!

# Force password change on first login
# (systemd service that runs once)

# Useful packages
environment.systemPackages = with pkgs; [
  neovim
  git
  curl
  wget
  btop
  bluetuith       # TUI bluetooth manager
  wirelesstools
  iw
];

# Console readable on small screen
console.font = "ter-v24n";  # Slightly smaller than v32n

# User setup
users.users.uconsole = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  initialPassword = "changeme";  # Expired on first boot
};
```

## Image Flavors

### Minimal
- TTY only
- NetworkManager + SSH
- ~500MB image
- For: Power users who want to build their own

### Hyprland
- Hyprland + Waybar
- Foot terminal
- Minimal app set
- A button mapped to Super
- For: Tiling WM enthusiasts

### Gnome Touch (future)
- Modified Gnome with:
  - Auto-hiding top bar
  - Large touch targets
  - On-screen keyboard
- For: Touch-friendly experience

## Monthly Maintenance Checklist

```
[ ] Check if nixpkgs updated the kernel
[ ] If yes: trigger GitHub Action or build on germain
[ ] Verify Cachix has new kernel
[ ] Every few months: build and publish new images to GitHub Releases
```

**Time estimate**: 15-30 min/month if automated, mostly just checking

## Roadmap

### Phase 1: Foundation (Now)
- [ ] Fork oom-hardware
- [ ] Fix base issues (NetworkManager, SSH auto-start)
- [ ] Set up Cachix
- [ ] Build first proper minimal image
- [ ] Basic README

### Phase 2: Automation
- [ ] GitHub Actions for weekly builds
- [ ] Self-hosted runner on germain (optional)
- [ ] Automated image uploads to GitHub Releases

### Phase 3: Flavors
- [ ] Hyprland image with good defaults
- [ ] Document the Hyprland setup

### Phase 4: Polish
- [ ] nixos-uconsole.org (simple landing page)
- [ ] Better docs
- [ ] Touch-friendly desktop option

## Upstream Relationship

- Keep oom-hardware as upstream
- Our fork adds:
  - Better defaults
  - Cachix integration
  - Multiple image flavors
  - Documentation
- Contribute fixes back to upstream when applicable

## Learning Resources

As you learn Nix through this project:

1. **Flake structure**: Study oom-hardware's flake.nix
2. **NixOS modules**: How options/config work
3. **Cross-compilation**: The binfmt/QEMU stuff
4. **Cachix**: Binary cache workflow
5. **SD image building**: How sd-image.nix works

## Notes

- CM5 support: Add later when you get hardware
- 4G module: Separate doc, keep modular
- Home Manager: Document as optional advanced setup
