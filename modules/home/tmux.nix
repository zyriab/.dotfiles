{ pkgs, ... }:
let
  tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-menus";
    version = "2.2.33";
    src = pkgs.fetchFromGitHub {
      owner = "jaclu";
      repo = "tmux-menus";
      rev = "v2.2.33";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;

    extraConfig = ''
      # Undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';

    plugins = [
      {
        plugin = tmux-menus;
        extraConfig = "set -g @menus_trigger f";
      }
    ];
  };
}
