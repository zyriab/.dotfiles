{ pkgs, lib, ... }:
{
  # ARM emulation for building aarch64 packages (e.g., uConsole)
  # Required because the kernel package requires system = "aarch64-linux"
  boot.binfmt.emulatedSystems = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
    "aarch64-linux"
  ];
  nix.settings.extra-platforms = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
    "aarch64-linux"
  ];

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

  # Used for removable media automounting
  services.udisks2.enable = true;

  # QMK keyboard support and utilities
  environment.systemPackages = with pkgs; [
    qmk
    evtest # For testing input devices
    wl-clipboard # Wayland clipboard utilities
  ];

  services.udev.packages = with pkgs; [
    qmk-udev-rules
    via
    vial
  ];

  # xremap for keyboard and trackball remapping
  services.xremap = {
    enable = true;
    withWlroots = true; # For Hyprland support
    mouse = true; # Enable mouse device monitoring
    watch = true; # Watch for new devices (helps with BT reconnection)

    config.modmap = [
      {
        name = "Global";
        remap = {
          # Caps Lock: Escape on tap, Ctrl on hold
          CapsLock = {
            held = "Ctrl_L";
            alone = "Esc";
            alone_timeout_millis = 200;
          };
        };
      }
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
