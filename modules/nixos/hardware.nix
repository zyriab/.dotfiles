{ pkgs, ... }:
{
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          # Shows battery charge of connected devices (if supported)
          Experimental = true;
          # Enable both Classic and BLE
          ControllerMode = "dual";
        };
        Policy = {
          # Reconnect on link loss
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,4,8,16,32,64";
        };
      };
    };

    keyboard.qmk.enable = true;

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

  };

  # QMK keyboard support
  environment.systemPackages = with pkgs; [
    qmk
    evtest # For testing input devices
  ];

  services.udev.packages = with pkgs; [
    qmk-udev-rules
    via
    vial
  ];

  # xremap for trackball button remapping
  services.xremap = {
    enable = true;
    withWlroots = true; # For Hyprland support
    mouse = true; # Enable mouse device monitoring
    watch = true; # Watch for new devices (helps with BT reconnection)

    config.modmap = [
      {
        name = "Kensington Trackball";
        remap = {
          # Remap top-right button (BTN_SIDE) to right click (BTN_RIGHT)
          BTN_SIDE = "BTN_RIGHT";
        };
      }
    ];
  };

}
