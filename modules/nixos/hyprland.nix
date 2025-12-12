{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;


  environment.systemPackages = with pkgs; [
    wofi
    waybar
    playerctl
    hyprshot
    hyprmon
    hypridle
    hyprcursor
    nwg-look
    brightnessctl
    swaynotificationcenter
    libnotify
    hyprpaper
    hyprdim
    fuzzel
  ];
}
