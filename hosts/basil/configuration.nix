{
  pkgs,
  pkgs-kernel,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/apps.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/browsers.nix
    inputs.xremap.nixosModules.default
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.logind.settings.Login = {
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "ignore";
  };

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs-kernel.linuxPackages_6_17;

  networking.hostName = "basil";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalization properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "fr_BE.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_BE.UTF-8";
    LC_IDENTIFICATION = "fr_BE.UTF-8";
    LC_MEASUREMENT = "fr_BE.UTF-8";
    LC_MONETARY = "fr_BE.UTF-8";
    LC_NAME = "fr_BE.UTF-8";
    LC_NUMERIC = "fr_BE.UTF-8";
    LC_PAPER = "fr_BE.UTF-8";
    LC_TELEPHONE = "fr_BE.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "eurosign:e"; # AltGr+E for Euro sign
  };

  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account.
  users.users.zyr = {
    isNormalUser = true;
    description = "zyr";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "video"
    ];
    packages = [ ];
    shell = pkgs.zsh;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "zyr" = import ./home.nix;
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "zyr" ];
      commands = [
        {
          command = "ALL";
          options = [
            "SETENV"
          ];
        }
      ];
    }
  ];

  virtualisation.docker = {
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        dns = [
          "8.8.8.8"
          "8.8.4.4"
          "1.1.1.1"
        ];
      };
    };
  };

  # Display manager for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  # Fingerprint reader
  services.fprintd.enable = true;

  # Allow both password and fingerprint for sudo
  security.pam.services.sudo.fprintAuth = true;

  # Firwmare update
  services.fwupd.enable = true;

  # Power management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # 1Password browser integration - allow Zen browser
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      zen
      chromium
    '';
    mode = "0644";
  };

  environment.systemPackages = [ ];

  programs = {
    hyprland.enable = true;

    nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };

    # TODO: Check if nix-ld is still needed
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        prettierd
      ];
    };

    zsh.enable = true;
  };

  services.kmscon = {
    enable = true;
    useXkbConfig = true;
    fonts = [
      {
        name = "Fira Mono";
        package = pkgs.fira;
      }
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "25.11";

}
