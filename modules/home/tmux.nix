{ pkgs, ... }:
let
  tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-menus";
    version = "2.2.33";
    src = pkgs.fetchFromGitHub {
      owner = "jaclu";
      repo = "tmux-menus";
      rev = "v2.2.33";
      hash = "sha256-UPWsa7sFy6P3Jo3KFEvZrz4M4IVDhKI7T1LNAtWqTT4=";
    };
  };

  tmux-battery = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-battery";
    version = "1.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-battery";
      rev = "v1.3.0";
      hash = "sha256-4Skji4K3Wib/EsBm91Ab8AHnnr6Cau9jcE+NeV4JcbU=";
    };
  };
in
{
  # Dependencies
  home.packages = with pkgs; [
    upower # Needed by tmux-battery
    ghostty.terminfo # For SSH sessions from ghostty
  ];

  programs.tmux = {
    enable = true;
    shortcut = "Space";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    escapeTime = 5; # Addresses vim mode switching delay (http://superuser.com/a/252717/65504)
    keyMode = "vi";
    focusEvents = true;
    mouse = true;
    newSession = true;
    resizeAmount = 30;
    aggressiveResize = true;
    clock24 = true;

    extraConfig = ''
      # Easier and faster switching between next/prev window
      bind C-p previous-window
      bind C-n next-window

      # Switching current window position
      bind h swap-window -t -1 \;  previous-window
      bind l swap-window -t +1 \; next-window

      set -g status-right '#{battery_status_bg} Batt: #{battery_icon} #{battery_percentage} #{battery_remain} | %a %h-%d %H:%M'

      # Increasing messages display from 750ms to 4s
      set -g display-time 4000

      set -g status-interval 5

      # Undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';

    plugins = [
      {
        plugin = tmux-menus;
        extraConfig = "set -g @menus_trigger '/'";
      }
      {
        plugin = tmux-battery;
      }
    ];
  };
}
