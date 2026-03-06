{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    winetricks
    prismlauncher
  ];

  programs.steam.enable = true;
}
