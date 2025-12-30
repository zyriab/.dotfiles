{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "microboi";
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
    };
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
  ];

  system.stateVersion = "25.11";
}
