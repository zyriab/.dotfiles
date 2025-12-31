{ pkgs, ... }:
{
  # uConsole-specific Hyprland configuration
  # 5" 720x1280 display (portrait, rotated to landscape = 1280x720)

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
          timeout = 120;
          on-timeout = "brightnessctl -s set 10%";
          on-resume = "brightnessctl -r";
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
          timeout = 600;
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

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 2;
          blur_size = 3;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 40";
          outline_thickness = 2;
          inner_color = "rgba(0d111780)";
          outer_color = "rgb(79c0ff)";
          check_color = "rgb(39c5cf)";
          fail_color = "rgb(ec8e2c)";
          font_color = "rgb(c9d1d9)";
          fade_on_empty = false;
          rounding = 6;
          font_family = "monospace";
          placeholder_text = "<span foreground=\"##c9d1d9\">$USER</span>";
          fail_text = "<span foreground=\"##ec8e2c\">$PAMFAIL</span>";
          dots_spacing = 0.2;
          dots_center = true;
          position = "0, -10";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # TIME - smaller for the tiny screen
        {
          monitor = "";
          text = "$TIME";
          color = "rgb(c9d1d9)";
          font_size = 48;
          font_family = "monospace";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.swaync.enable = true;

  home.packages = with pkgs; [
    waybar
    playerctl
    hyprshot
    hyprlock
    brightnessctl
    swaynotificationcenter
    libnotify
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # uConsole display: 720x1280 native, rotated 90° for landscape
      monitor = [
        "DSI-1,720x1280@60,0x0,1,transform,1"
      ];

      # Program variables
      "$terminal" = "foot";
      "$menu" = "fuzzel";
      "$lockscreen" = "hyprlock";
      "$mainMod" = "SUPER";

      # Autostart
      exec-once = [
        "waybar"
        "swaync"
      ];

      # Environment
      env = [
        "XCURSOR_SIZE,20"
      ];

      # General - tighter for small screen
      general = {
        gaps_in = 2;
        gaps_out = 4;
        border_size = 1;
        "col.active_border" = "rgba(79c0ffff)";
        "col.inactive_border" = "rgba(0d1117aa)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration - minimal for performance
      decoration = {
        rounding = 4;
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        shadow = {
          enabled = false;
        };

        blur = {
          enabled = false;
        };
      };

      # Animations - simpler for performance
      animations = {
        enabled = true;
        first_launch_animation = false;

        bezier = [
          "quick, 0.15, 0, 0.1, 1"
        ];

        animation = [
          "windows, 1, 2, quick"
          "fade, 1, 2, quick"
          "workspaces, 1, 2, quick, slide"
        ];
      };

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      # Misc
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vfr = true;
      };

      # Input
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
      ];

      # Keybindings
      bind = [
        # Program launches
        "$mainMod, T, exec, $terminal"
        "$mainMod, SPACE, exec, $menu"
        "$mainMod, Return, exec, $terminal"

        # Window management
        "$mainMod, Q, killactive"
        "$mainMod ALT, L, exec, $lockscreen"
        "$mainMod, V, togglefloating"
        "$mainMod, F, fullscreen, 1"
        "$mainMod SHIFT, F, fullscreen, 0"
        "$mainMod, P, pseudo"
        "$mainMod, M, togglesplit"

        # Focus movement (vim keys)
        "$mainMod, H, movefocus, l"
        "$mainMod, J, movefocus, d"
        "$mainMod, K, movefocus, u"
        "$mainMod, L, movefocus, r"

        # Focus movement (arrows)
        "$mainMod, left, movefocus, l"
        "$mainMod, down, movefocus, d"
        "$mainMod, up, movefocus, u"
        "$mainMod, right, movefocus, r"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"

        # Move to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"

        # Cycle workspaces
        "$mainMod, bracketleft, workspace, -1"
        "$mainMod, bracketright, workspace, +1"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Move windows
        "$mainMod CTRL, H, movewindow, l"
        "$mainMod CTRL, J, movewindow, d"
        "$mainMod CTRL, K, movewindow, u"
        "$mainMod CTRL, L, movewindow, r"
      ];

      # Repeating binds (for resizing)
      binde = [
        "$mainMod SHIFT, H, resizeactive, -40 0"
        "$mainMod SHIFT, J, resizeactive, 0 40"
        "$mainMod SHIFT, K, resizeactive, 0 -40"
        "$mainMod SHIFT, L, resizeactive, 40 0"
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
        ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Mouse binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  # Waybar config for uConsole
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          format-charging = " {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
        };

        network = {
          format-wifi = " ";
          format-ethernet = " ";
          format-disconnected = "󰖪 ";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
        };

        pulseaudio = {
          format = "{icon}";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
      };
    };

    style = ''
      * {
        font-family: "monospace";
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(13, 17, 23, 0.9);
        color: #c9d1d9;
      }

      #workspaces button {
        padding: 0 4px;
        color: #8b949e;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.active {
        color: #79c0ff;
        border-bottom: 2px solid #79c0ff;
      }

      #clock, #battery, #network, #pulseaudio {
        padding: 0 8px;
      }

      #battery.warning {
        color: #d29922;
      }

      #battery.critical {
        color: #f85149;
      }
    '';
  };
}
