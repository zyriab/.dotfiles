{ pkgs, lib, ... }:
let
  # Charge stops at this % and only resumes below (limit - hysteresis).
  # Great for a mostly-docked laptop to reduce Li-ion wear.
  limit = 80;
in
{
  environment.systemPackages = with pkgs; [
    fw-ectool
    framework-tool
  ];

  systemd.services.framework-charge-limit = {
    description = "Set Framework EC battery charge limit to ${toString limit}%";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.fw-ectool}/bin/ectool fwchargelimit ${toString limit}";
    };
  };
}
