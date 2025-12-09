{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Work
    slack
    dbeaver-bin

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

    # Gaming
    wineWowPackages.stable
    winetricks
  ];

  programs.steam.enable = true;
}
