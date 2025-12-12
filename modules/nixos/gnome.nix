{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = [ pkgs.totem ];


  environment.systemPackages = with pkgs; [
    xclip
    gnome-session
    xorg.xkill
  ];
}
