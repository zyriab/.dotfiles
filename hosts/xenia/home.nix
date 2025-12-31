{ pkgs, ... }:

{
  imports = [
    ../../modules/home/git.nix
    ../../modules/home/zsh.nix
    ../../modules/home/neovim.nix
    ../../modules/home/tools.nix
    ../../modules/home/tmux.nix
    ../../modules/home/fuzzel.nix
    ../../modules/home/dev.nix
    ../../modules/home/claude-code.nix
    # Custom hyprland config for uConsole
    ./hyprland.nix
  ];

  home.username = "zyr";
  home.homeDirectory = "/home/zyr";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    foot           # Lightweight terminal for small screen
    legcord        # ARM-compatible Discord client
  ];

  programs.home-manager.enable = true;
}
