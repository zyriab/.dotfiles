{ pkgs, inputs, ... }:
{
  programs.hyprpanel = {
    enable = true;
    package = inputs.hyprpanel.packages.${pkgs.system}.default;
    settings = {
      bar.customModules.updates.pollingInterval = 1440000;
      bar.launcher.icon_size = 24;
      bar.launcher.icon = "";
      bar.layouts = {
        "0" = {
          left = [
            "dashboard"
            "workspaces"
            "windowtitle"
          ];
          middle = [ "media" ];
          right = [
            "volume"
            "clock"
            "custom.mst_clock"
            "notifications"
          ];
        };
      };
      bar.customModules.mst_clock = {
        icon = "";
        exec = "TZ='America/Denver' date +'%H:%M'";
        interval = 60000;
        tooltip = "MST Time";
      };
      # Minimal clean theme based on GitHub Dark Colorblind
      theme.bar.outer_spacing = "0px";
      theme.bar.buttons.y_margins = "0px";
      theme.bar.buttons.spacing = "0.3em";
      theme.bar.buttons.padding_x = "0.8rem";
      theme.bar.buttons.padding_y = "0.3rem";
      theme.bar.transparent = true;
      theme.bar.floating = false;
      theme.bar.buttons.radius = "8px";
      theme.bar.buttons.style = "default";
      theme.bar.buttons.monochrome = true;

      # Font configuration
      theme.font.name = "JetBrainsMono Nerd Font Propo";
      theme.font.size = "12px";

      # Notification styling
      theme.notification.border_radius = "8px";
      theme.notification.background = "rgba(13, 17, 23, 0.95)";
      theme.notification.actions.background = "rgba(88, 166, 255, 0.2)";
      theme.notification.actions.text = "rgb(201, 209, 217)";
      theme.notification.label.text = "rgb(201, 209, 217)";
      theme.notification.border = "rgb(121, 192, 255)";
      theme.notification.text = "rgb(201, 209, 217)";
      theme.notification.time = "rgb(139, 148, 158)";

      # OSD (on-screen display) styling
      theme.osd.enable = true;
      theme.osd.orientation = "vertical";
      theme.osd.location = "right";
      theme.osd.radius = "8px";
      theme.osd.margins = "0px 10px 0px 0px";

      # Bar color overrides
      theme.bar.background = "rgba(13, 17, 23, 0.9)";

      menus.clock.time.military = true;
      menus.clock.weather.unit = "metric";
    };
  };

  # Hyprpanel dependencies
  home.packages = with pkgs; [
    # Required dependencies
    dart-sass
    upower
    gvfs
    gtksourceview3
    libgtop
    bluez-tools
    grimblast
    hyprpicker
  ];

}
