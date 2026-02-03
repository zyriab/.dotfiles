{ inputs, ... }:

{
  imports = [
    ../../modules/home/desktop.nix
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
    ../../modules/home/automount.nix
    ../../modules/home/chromium.nix
    ../../modules/home/zen-browser.nix
    ../../modules/home/electron-wayland-fixes.nix
    ../../modules/home/gtk.nix
    ../../modules/home/crush.nix
    inputs.hyprdynamicmonitors.homeManagerModules.default
  ];

  home = {
    username = "zyr";
    homeDirectory = "/home/zyr";

    packages = [ ];

    file = { };

    sessionVariables = { };

    stateVersion = "25.11";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs = {
    home-manager.enable = true;
  };
}
