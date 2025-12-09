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
  ];

  services.udev.packages = with pkgs; [
    qmk-udev-rules
    via
    vial
  ];

}
