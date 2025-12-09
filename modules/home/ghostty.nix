{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraMono Nerd Font Mono";
      font-size = 9;
      theme = "GitHub Dark Colorblind";
      background-opacity = 0.9;
      unfocused-split-opacity = 0.8;
      mouse-hide-while-typing = true;
      cursor-invert-fg-bg = true;
      cursor-style = "bar";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      gtk-custom-css = "tab-style.css";
      keybind = [
        "shift+enter=text:\\x1b\\r"
        "ctrl+shift+d=close_surface"
        "ctrl+shift+c=copy_to_clipboard"
      ];
    };
  };

  # Custom tab styling
  xdg.configFile."ghostty/tab-style.css".text = ''
    tabbar tabbox {
        margin: 0;
        padding: 0;
        min-height: 10px;
        background-color: #1a1a1a;
        font-family: fira-mono;
        border-radius: 0 !important;
    }

    tabbar tabbox tab {
        margin: 0;
        padding: 0;
        color: #9ca3af;
        border-radius: 0 !important;
    }

    tabbar tabbox tab:selected {
        background-color: #2d2d2d;
        color: #ffffff;
        border-radius: 0 !important;
    }

    tabbar tabbox tab label {
        font-size: 13px;
    }
  '';
}
