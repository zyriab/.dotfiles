{ pkgs, ... }:
let
  hyprshade-focus = pkgs.writeShellScript "hyprshade-focus" ''
    STATE_FILE="/tmp/hyprshade-state"
    # States: "auto" (follow schedule), "on" (forced on), "off" (forced off)

    get_state() {
      [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo "auto"
    }

    handle() {
      state=$(get_state)

      case $1 in
        activewindow\>\>*ghostty*)
          # Always disable when ghostty focused (unless forced off already)
          [ "$state" != "off" ] && ${pkgs.hyprshade}/bin/hyprshade off
          ;;
        activewindow\>\>*)
          case $state in
            on) ${pkgs.hyprshade}/bin/hyprshade on blue-light-filter ;;
            off) ${pkgs.hyprshade}/bin/hyprshade off ;;
            auto) ${pkgs.hyprshade}/bin/hyprshade auto ;;
          esac
          ;;
      esac
    }

    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
      handle "$line"
    done
  '';

  hyprshade-toggle = pkgs.writeShellScript "hyprshade-toggle" ''
    STATE_FILE="/tmp/hyprshade-state"
    # Cycle: auto -> on -> off -> auto

    current=$([ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo "auto")

    case $current in
      auto)
        echo "on" > "$STATE_FILE"
        ${pkgs.hyprshade}/bin/hyprshade on blue-light-filter
        ${pkgs.libnotify}/bin/notify-send -t 2000 "Hyprshade" "Forced ON"
        ;;
      on)
        echo "off" > "$STATE_FILE"
        ${pkgs.hyprshade}/bin/hyprshade off
        ${pkgs.libnotify}/bin/notify-send -t 2000 "Hyprshade" "Forced OFF"
        ;;
      off)
        echo "auto" > "$STATE_FILE"
        ${pkgs.hyprshade}/bin/hyprshade auto
        ${pkgs.libnotify}/bin/notify-send -t 2000 "Hyprshade" "Auto (schedule)"
        ;;
    esac
  '';
in
{
  home.packages = [
    pkgs.hyprshade
    (pkgs.writeShellScriptBin "hyprshade-toggle" (builtins.readFile hyprshade-toggle))
  ];

  xdg.configFile."hypr/hyprshade.toml".text = ''
    [[shades]]
    name = "blue-light-filter"
    start_time = 19:00:00
    end_time = 06:00:00

    [shades.config]
    temperature = 3700
  '';

  # Systemd service to handle focus-based hyprshade toggling
  systemd.user.services.hyprshade-focus = {
    Unit = {
      Description = "Hyprshade focus handler - disable for ghostty";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'echo auto > /tmp/hyprshade-state'";
      ExecStart = "${hyprshade-focus}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
