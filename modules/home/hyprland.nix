{ config, pkgs, inputs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;

    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    settings = {
      # Monitor configuration
      monitor = [
        "eDP-1,2560x1440@60.00,3520x1080,1.66"
        "HDMI-A-2,1920x1080@60.00,1600x0,1.00"
      ];

      # Program variables
      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$calculator" = "gnome-calculator";
      "$menu" = "fuzzel";
      "$lockscreen" = "hyprlock";
      "$browser" = "chromium --ozone-platform-hint=auto";
      "$notes" = "obsidian";
      "$mainMod" = "SUPER";

      # Autostart
      exec-once = [
        "waybar &"
        "swaync &"
        "hypridle &"
        "hyprpaper &"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # Permissions
      permission = [
        "/usr/(bin|local/bin)/hyprpm, plugin, allow"
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(79c0ffff)";
        "col.inactive_border" = "rgba(0d1117aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = "yes, please :)";

        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1"
          "quick, 0.15, 0, 0.1, 1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
          "zoomFactor, 1, 7, quick"
        ];
      };

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      # Input
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
        };
      };

      # Gestures
      gesture = "3, horizontal, workspace";

      # Device-specific config
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Window rules
      windowrulev2 = [
        "float, class:^(com\\.mitchellh\\.ghostty)$, title:^(scratch_term)$"
        "float, class:^(org\\.gnome\\.Calculator)$"
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      # Keybindings
      bind = [
        # Program launches
        "$mainMod, T, exec, $terminal"
        "$SUPER_ALT, T, exec, $terminal --title=scratch_term"
        "$mainMod, B, exec, $browser"
        "$mainMod, F, exec, $fileManager"
        "$mainMod, SPACE, exec, $menu"
        "$mainMod, C, exec, $calculator"
        "$mainMod, N, exec, $notes"

        # Window management
        "$mainMod, Q, killactive"
        "$SUPER_ALT SHIFT, L, exit"
        "$SUPER_ALT, L, exec, $lockscreen"
        "$mainMod, V, togglefloating"
        "$SUPER_ALT, V, exec, sh -c 'if hyprctl activewindow -j | jq -e \".floating == true\" > /dev/null; then hyprctl dispatch focuswindow tiled; else hyprctl dispatch focuswindow floating; fi'"
        "$mainMod, P, pseudo"
        "$mainMod, M, togglesplit"

        # Focus movement (arrows)
        "$mainMod, left, movefocus, l"
        "$mainMod, down, movefocus, d"
        "$mainMod, up, movefocus, u"
        "$mainMod, right, movefocus, r"

        # Focus movement (vim keys)
        "$mainMod, H, movefocus, l"
        "$mainMod, J, movefocus, d"
        "$mainMod, K, movefocus, u"
        "$mainMod, L, movefocus, r"

        # Workspace switching (arrows) - cycle through workspaces
        "CTRL, left, split-workspace, e-1"
        "CTRL, right, split-workspace, e+1"

        # Switch focus between monitors
        "$mainMod, bracketleft, focusmonitor, -1"
        "$mainMod, bracketright, focusmonitor, +1"

        # Workspace switching (numbers) - per-monitor workspaces
        "$mainMod, 1, split-workspace, 1"
        "$mainMod, 2, split-workspace, 2"
        "$mainMod, 3, split-workspace, 3"
        "$mainMod, 4, split-workspace, 4"
        "$mainMod, 5, split-workspace, 5"
        "$mainMod, 6, split-workspace, 6"
        "$mainMod, 7, split-workspace, 7"
        "$mainMod, 8, split-workspace, 8"
        "$mainMod, 9, split-workspace, 9"
        "$mainMod, 0, split-workspace, 10"

        # Move to workspace - per-monitor workspaces
        "$SUPER_ALT, 1, split-movetoworkspacesilent, 1"
        "$SUPER_ALT, 2, split-movetoworkspacesilent, 2"
        "$SUPER_ALT, 3, split-movetoworkspacesilent, 3"
        "$SUPER_ALT, 4, split-movetoworkspacesilent, 4"
        "$SUPER_ALT, 5, split-movetoworkspacesilent, 5"
        "$SUPER_ALT, 6, split-movetoworkspacesilent, 6"
        "$SUPER_ALT, 7, split-movetoworkspacesilent, 7"
        "$SUPER_ALT, 8, split-movetoworkspacesilent, 8"
        "$SUPER_ALT, 9, split-movetoworkspacesilent, 9"
        "$SUPER_ALT, 0, split-movetoworkspacesilent, 10"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$SUPER_ALT, S, movetoworkspace, special:magic"

        # Scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Move window with keys
        "$mainMod CTRL, left, movewindow, l"
        "$mainMod CTRL, down, movewindow, d"
        "$mainMod CTRL, up, movewindow, u"
        "$mainMod CTRL, right, movewindow, r"

        # Screenshots
        "SHIFT, Print, exec, hyprshot -m region --clipboard-only"
        "ALT, Print, exec, hyprshot -m window --clipboard-only"
      ];

      # Repeating binds (for resizing)
      binde = [
        "$SUPER_SHIFT, left, resizeactive, -60 0"
        "$SUPER_SHIFT, down, resizeactive, 0 60"
        "$SUPER_SHIFT, up, resizeactive, 0 -60"
        "$SUPER_SHIFT, right, resizeactive, 60 0"
      ];

      # Locked binds (work even when locked)
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Locked + repeating binds (for volume/brightness)
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Mouse binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Plugins
      plugin = {
        split-monitor-workspaces = {
          count = 10;
          keep_focused = 0;
          enable_notifications = 0;
          enable_persistent_workspaces = 1;
          enable_wrapping = 1;
        };

        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
          workspace_method = "center current";
          gesture_distance = 300;
        };
      };
    };
  };
}
