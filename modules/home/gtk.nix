{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # GTK theme configuration for dark mode
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    # Force dark mode for all GTK applications
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # dconf settings for GNOME apps dark mode
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      color-scheme = "prefer-dark";
    };

    # Specific settings for GNOME Calculator
    "org/gnome/calculator" = {
      button-mode = "basic";
      show-thousands = false;
      show-zeroes = false;
      word-size = 64;
    };

    # File manager (Nautilus) settings
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = false;
    };

    "org/gnome/nautilus/list-view" = {
      use-tree-view = false;
    };
  };

  # Ensure required packages are available
  home.packages = with pkgs; [
    gnome-themes-extra
    adwaita-icon-theme
    dconf
  ];
}
