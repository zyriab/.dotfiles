{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Notes
    (callPackage ../../pkgs/inkdrop.nix { })

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
    gnome-calculator
    nautilus
    gparted

    (callPackage ../../pkgs/dbeaver-patched.nix { inherit pkgs; })
  ];
}
