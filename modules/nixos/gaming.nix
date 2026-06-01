{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wineWow64Packages.stable
    winetricks
    prismlauncher
  ];

  programs.steam.enable = true;
}
