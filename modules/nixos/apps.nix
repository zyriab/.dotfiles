{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Work
    slack

    # Media
    spotify
    vlc
    deluge
    discord

    # Utilities
    keepassxc
    _1password-gui
    obsidian
    libreoffice
    chromium
    gnome-calculator
    nautilus

    (callPackage ../../pkgs/dbeaver-patched.nix { inherit pkgs; })

    # Gaming
    wineWowPackages.stable
    winetricks
  ];

  programs.steam.enable = true;
}
