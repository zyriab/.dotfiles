{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/nixos/audio.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/browsers.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Suppress kernel messages on console (fixes tuigreet UI)
  boot.consoleLogLevel = 0;

  # Boot menu timeout (seconds) for generation selection
  boot.loader.timeout = 5;

  networking.hostName = "xenia";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";

  users.users = {
    root = {
      initialPassword = "changeme";
    };

    zyr = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
      ];
      initialPassword = "changeme";
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;

  # GPU/Mesa drivers
  hardware.graphics.enable = true;

  # Used for removable media automounting
  services.udisks2.enable = true;

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
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'hyprland > /dev/null 2>&1'";
        user = "greeter";
      };
    };
  };

  # Power management
  services.upower.enable = true;
  powerManagement.enable = true;

  # 4G module support (optional expansion card)
  hardware.uc-4g.enable = true;

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
    font = "ter-v24n";
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
