{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "FiraMono Nerd Font Mono:size=11";
        dpi-aware = "no";
        prompt = " > ";
        icon-theme = "hicolor";
        terminal = "ghostty";
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 10;
        inner-pad = 10;
      };

      colors = {
        background = "0d1117f0";
        text = "c9d1d9ff";
        match = "79c0ffff";
        selection = "58a6ff80";
        selection-text = "c9d1d9ff";
        selection-match = "fdac54ff";
        border = "79c0ffff";
      };

      border = {
        width = 2;
        radius = 8;
      };
    };
  };
}
