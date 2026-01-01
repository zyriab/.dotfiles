{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/nixos/audio.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/browsers.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Disable LVM in initrd - we don't use LVM and it causes patchelf errors
  # with the current nixpkgs (lvm/dmsetup are script wrappers, not ELF binaries)
  boot.initrd.services.lvm.enable = lib.mkForce false;

  networking.hostName = "xenia";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";

  users.users = {
    root = {
      initialPassword = "changeme";
    };

    zyr = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      initialPassword = "changeme";
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;

  # GPU/Mesa drivers
  hardware.graphics.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Login manager - greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Power management
  services.upower.enable = true;
  powerManagement.enable = true;

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.zyr = import ./home.nix;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = true;
    };
  };

  console = {
    earlySetup = true;
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    btop
    wirelesstools
    iw
  ];

  system.stateVersion = "25.11";
}
