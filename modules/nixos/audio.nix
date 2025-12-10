{ ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.playerctld.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.extraConfig."50-bluez-config" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            { "node.name" = "~bluez_output.*"; }
            { "node.name" = "~bluez_input.*"; }
          ];
          actions = {
            update-props = {
              # Disable suspend timeout to keep Bluetooth devices connected
              "session.suspend-timeout-seconds" = 0;
            };
          };
        }
      ];
    };
  };
}
