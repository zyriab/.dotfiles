{ pkgs, ... }:
{

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 150;
          on-timeout = "brightnessctl -sd tpacpi::kbd_backlight set 0";
          on-resume = "brightnessctl -rd tpacpi::kbd_backlight";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        disable_loading_bar = true;
      };

      auth = {
        fingerprint.enabled = true;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 4;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 50";
          outline_thickness = 2;
          inner_color = "rgba(0d111780)";
          outer_color = "rgb(79c0ff)";
          check_color = "rgb(39c5cf)";
          fail_color = "rgb(ec8e2c)";
          capslock_color = "rgb(ef0fff)";
          font_color = "rgb(c9d1d9)";
          fade_on_empty = false;
          rounding = 8;
          font_family = "FiraMono Nerd Font Mono";
          placeholder_text = "<span foreground=\"##c9d1d9\">󰌾  Logged in as <span foreground=\"##c9d1d9\">$USER</span></span>";
          fail_text = "<span foreground=\"##ec8e2c\">$PAMFAIL</span>";
          dots_spacing = 0.3;
          dots_center = true;
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # TIME
        {
          monitor = "";
          text = "$TIME";
          color = "rgb(c9d1d9)";
          font_size = 90;
          font_family = "FiraMono Nerd Font Mono";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        # DATE
        {
          monitor = "";
          text = "cmd[update:60000] date +\"%A, %d %B %Y\"";
          color = "rgb(8b949e)";
          font_size = 25;
          font_family = "FiraMono Nerd Font Mono";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
        # CAPS LOCK WARNING
        {
          monitor = "";
          text = "cmd[update:100] if [ $(cat /sys/class/leds/input*::capslock/brightness 2>/dev/null | head -1) = \"1\" ]; then echo \"󰪛  CAPS LOCK\"; fi";
          color = "rgb(ef0fff)";
          font_size = 16;
          font_family = "FiraMono Nerd Font Mono";
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hyprpaper.enable = true;

  xdg.configFile."hypr/hyprpaper.conf" = {
    force = true;
    text =
      let
        wallpaper = "/mnt/data/Pictures/Wallpapers/snowy-canopy.jpg";
      in
      ''
        wallpaper {
          monitor = eDP-2
          path = ${wallpaper}
        }
      '';
  };

  };

  services.swaync.enable = true;

  # Custom systemd service for hyprdim
  systemd.user.services.hyprdim = {
    Unit = {
      Description = "Hyprdim - Automatically dim inactive windows";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.hyprdim}/bin/hyprdim --strength 0.25 --duration 300 --dialog-dim 0.2 --fade 3";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.packages = with pkgs; [
    wofi
    waybar
    playerctl
    hyprshot
    hyprcursor
    hyprlock
    nwg-look
    brightnessctl
    swaynotificationcenter
    libnotify
    hyprpaper
    hyprdim

    # Fallback term if system is FUBAR
    kitty
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # plugins = [
    #   inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
    # ];

    settings =
      let
        # Monitor configuration variables
        # laptopMonitorConfig = "eDP-1,2560x1440,1920x1000,1.6";
        laptopMonitorConfig = "eDP-1,disable";

      in
      {
        # Monitor configuration
        monitor = [
          laptopMonitorConfig
          "HDMI-A-2,1920x1080@60.00,0x0,1.00"
        ];

        # Program variables
        "$terminal" = "ghostty";
        "$fileManager" = "nautilus";
        "$calculator" = "gnome-calculator";
        "$menu" = "fuzzel";
        "$lockscreen" = "hyprlock";
        # Ozone thing is needed to fix some rendering issues
        "$browser" = "zen";
        "$notes" = "obsidian";
        "$mainMod" = "SUPER";

        # Autostart (other services managed via systemd)
        exec-once = [ ];

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
          # Floating terminal
          "float, class:^(com\\.mitchellh\\.ghostty)$, title:^(scratch_term)$"
          # Floating Blueman
          "float, class:^(\\.blueman-manager-wrapped)$"
          # Floating pwvucontrol
          "float, class:^(com.saivert.pwvucontrol)$"
          # Floating calculator
          "float, class:^(org\\.gnome\\.Calculator)$"
          # Suppress maximize events for all windows
          "suppressevent maximize, class:.*"
          # Don't focus empty XWayland floating windows (prevents focus on invisible windows)
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];

        # Keybindings
        bind = [
          # FIXME: dispatchers aren't recognized
          # "$mainMod, bracketleft, split-changemonitor, prev"
          # "$mainMod, bracketright, split-changemonitor, next"

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

          # Workspace switching (arrows)
          "CTRL, left, workspace, -1"
          "CTRL, right, workspace, +1"

          # Switch focus between monitors
          "$mainMod, bracketleft, focusmonitor, -1"
          "$mainMod, bracketright, focusmonitor, +1"

          # Workspace switching (numbers)
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move to workspace
          "$SUPER_ALT, 1, movetoworkspace, 1"
          "$SUPER_ALT, 2, movetoworkspace, 2"
          "$SUPER_ALT, 3, movetoworkspace, 3"
          "$SUPER_ALT, 4, movetoworkspace, 4"
          "$SUPER_ALT, 5, movetoworkspace, 5"
          "$SUPER_ALT, 6, movetoworkspace, 6"
          "$SUPER_ALT, 7, movetoworkspace, 7"
          "$SUPER_ALT, 8, movetoworkspace, 8"
          "$SUPER_ALT, 9, movetoworkspace, 9"
          "$SUPER_ALT, 0, movetoworkspace, 10"

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
          ", XF86PowerOff, exec, loginctl lock-session"
          ", switch:on:Lid Switch, exec, hyprctl keyword monitor eDP-2, disable"
          ", switch:off:Lid Switch, exec, hyprctl keyword monitor eDP-2, preferred, auto, 1"
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
          # split-monitor-workspaces = {
          #   count = 10;
          #   keep_focused = 0;
          #   enable_notifications = 0;
          #   enable_persistent_workspaces = 1;
          #   enable_wrapping = 1;
          # };

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
