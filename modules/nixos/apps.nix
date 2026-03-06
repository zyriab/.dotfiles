{ pkgs, ... }:
{

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "zyr" ];
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  environment.systemPackages = with pkgs; [
    # Notes
    (callPackage ../../pkgs/inkdrop.nix { })

    # Work
    slack
    zoom-us

    # Media
    spotify
    vlc
    deluge
    discord
    obs-studio

    # Utilities
    obsidian
    libreoffice
    gnome-calculator
    nautilus
  ];
}
