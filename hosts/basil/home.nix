{ ... }:

{
  imports = [
    ../../modules/home/git.nix
    ../../modules/home/zsh.nix
    ../../modules/home/neovim.nix
    ../../modules/home/tools.nix
    ../../modules/home/tmux.nix
    ../../modules/home/dev.nix
    ../../modules/home/ghostty.nix
    ../../modules/home/waybar.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/fuzzel.nix
    ../../modules/home/claude-code.nix
  ];

  home.username = "lab";
  home.homeDirectory = "/home/lab";

  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = [ ];

  home.file = { };

  programs = {
    home-manager.enable = true;
  };
}
