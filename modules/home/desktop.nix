{ pkgs, ... }:
{
  home.packages = [
    pkgs.redshift
  ];

  xdg.configFile."redshift/redshift.conf" = {
    text = ''
      [redshift]
      temp-day=6500
      temp-night=3700
      location-provider=manual

      [manual]
      lat=50.8
      lon=4.3
    '';
  };
}
