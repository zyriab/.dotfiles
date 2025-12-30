{ pkgs, ... }:

{
  imports = [
    ../../modules/home/tmux.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
