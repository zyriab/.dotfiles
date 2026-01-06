{ pkgs, ... }:
{

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "zyr" ];
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

    # Utilities
    obsidian
    libreoffice
    gnome-calculator
    nautilus

    (callPackage ../../pkgs/dbeaver-patched.nix { inherit pkgs; })
  ];
}
