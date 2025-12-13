{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    settings = {
      mainBar = {
        layer = "bottom";
        position = "top";
        height = 40;
        spacing = 2;
        exclusive = true;
        gtk-layer-shell = true;
        passthrough = false;
        fixed-center = true;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];

        modules-center = [
          "mpris"
        ];

        modules-right = [
          "network"
          "bluetooth"
          "pulseaudio"
          "clock"
          "clock#simpleclock"
          "clock#mst"
          "tray"
          "custom/notification"
          "custom/power"
        ];

        "custom/spotify" = {
          format = "  {}";
          return-type = "json";
          on-click = "playerctl -p spotify play-pause";
          on-click-right = "spotifatius toggle-liked";
          on-click-middle = "playerctl -p spotify next";
          exec = "spotifatius monitor";
        };

        mpris = {
          player = "spotify";
          dynamic-order = [
            "artist"
            "title"
          ];
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          status-icons = {
            paused = "";
          };
          player-icons = {
            default = "";
          };
        };

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{id}";
          all-outputs = true;
          disable-scroll = false;
          active-only = false;
        };

        "hyprland/window" = {
          format = "{title}";
        };

        tray = {
          show-passive-items = true;
          spacing = 10;
        };

        "clock#simpleclock" = {
          tooltip = false;
          format = " {:%H:%M %Z}";
        };

        "clock#mst" = {
          timezone = "America/Denver";
          tooltip = false;
          format = " {:%H:%M %Z}";
        };

        clock = {
          format = " {:%a %d %b}";
          locale = "en_GB.UTF-8";
          calendar = {
            format = {
              days = "<span weight='normal'>{}</span>";
              months = "<span color='#c9d1d9'><b>{}</b></span>";
              today = "<span color='#fdac54' weight='700'><u>{}</u></span>";
              weekdays = "<span color='#79c0ff'><b>{}</b></span>";
              weeks = "<span color='#39c5cf'><b>W{}</b></span>";
            };
            mode = "month";
            mode-mon-col = 1;
            on-scroll = 1;
          };
          tooltip-format = "<span color='#c9d1d9' font='FiraMono Nerd Font Mono 10'><tt><small>{calendar}</small></tt></span>";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰸈  muted";
          format-icons = {
            headphone = "󰋋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pwvucontrol";
        };

        network = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰈀 {ipaddr}";
          format-disconnected = "󰖪 Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ifname}: {ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
        };

        bluetooth = {
          format = "󰂯 {status}";
          format-disabled = "󰂲";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} ({device_battery_percentage}%)";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        "custom/sep" = {
          format = "|";
          tooltip = false;
        };

        "custom/power" = {
          tooltip = false;
          on-click = "wlogout -p layer-shell &";
          format = "⏻";
        };

        "custom/notification" = {
          escape = true;
          exec = "swaync-client -swb";
          exec-if = "which swaync-client";
          format = "{icon}";
          format-icons = {
            none = "󰅺";
            notification = "󰡟";
            dnd-none = "󰂛";
            dnd-notification = "󰂛";
          };
          on-click = "sleep 0.1 && swaync-client -t -sw";
          return-type = "json";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
          min-height: 0;
          min-width: 0;
          font-family: "FiraMono Nerd Font Mono", monospace;
          font-size: 11px;
          font-weight: 600;
      }

      window#waybar {
          transition-property: background-color;
          transition-duration: 0.5s;
          background-color: transparent;
      }

      #workspaces button {
          padding: 0.3rem 0.6rem;
          margin: 0.4rem 0.25rem;
          border-radius: 6px;
          background-color: #0d1117;
          color: #c9d1d9;
          opacity: 0.8;
      }

      #workspaces button:hover {
          color: #c9d1d9;
          background-color: #58a6ff;
      }

      #workspaces button.active {
          background-color: #0d1117;
          color: #ec8e2c;
      }

      #workspaces button.urgent {
          background-color: #0d1117;
          color: #ff9492;
      }

      #clock,
      #pulseaudio,
      #custom-logo,
      #custom-power,
      #custom-spotify,
      #custom-notification,
      #tray,
      #window,
      #mpris,
      #network,
      #bluetooth {
          padding: 0.3rem 0.6rem;
          margin: 0.4rem 0.25rem;
          border-radius: 6px;
          background-color: #0d1117;
          opacity: 0.8;
      }

      #mpris.playing {
          color: #39c5cf;
      }

      #mpris.paused {
          color: #8b949e;
      }

      #custom-sep {
          padding: 0px;
          color: #30363d;
      }

      window#waybar.empty #window {
          background-color: transparent;
      }

      #clock {
          color: #58a6ff;
      }

      #clock.simpleclock {
          color: #58a6ff;
      }

      #window {
          color: #c9d1d9;
      }

      #pulseaudio {
          color: #bc8cff;
      }

      #pulseaudio.muted {
          color: #8b949e;
      }

      #network {
          color: #79c0ff;
      }

      #network.disconnected {
          color: #8b949e;
      }

      #bluetooth {
          color: #58a6ff;
      }

      #bluetooth.disabled {
          color: #8b949e;
      }

      #custom-logo {
          color: #58a6ff;
      }

      #custom-power {
          color: #ff9492;
          min-width: 1.5rem;
      }

      #custom-notification {
          min-width: 1.5rem;
      }

      tooltip {
          background-color: rgba(13, 17, 23, 0.9);
          border: 2px solid #58a6ff;
          border-radius: 6px;
      }
    '';
  };
}
