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
    ../../modules/home/automount.nix
    ../../modules/home/chromium.nix
    ../../modules/home/electron-wayland-fixes.nix
    # Custom hyprland config for uConsole
    ./hyprland.nix
  ];

  home.username = "zyr";
  home.homeDirectory = "/home/zyr";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    legcord # ARM-compatible Discord client
    slacky # Unofficial Slack for ARM64
  ];

  # Foot terminal - larger font for small screen readability
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=12";
        pad = "8x8";
      };
      colors = {
        background = "0d1117";
        foreground = "c9d1d9";
      };
    };
  };

  programs.home-manager.enable = true;
}
