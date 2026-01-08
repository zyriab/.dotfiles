{ pkgs, ... }:
{
  security = {
    polkit.enable = true;

    sudo.extraRules = [
      {
        users = [ "zyr" ];
        commands = [
          {
            command = "ALL";
            options = [ "SETENV" ];
          }
        ];
      }
    ];
  };

  services.fprintd.enable = true;

  # Allow password OR fingerprint for greetd (not fingerprint only)
  security.pam.services.greetd = {
    enableGnomeKeyring = true;
    fprintAuth = false;
  };

  services.gnome.gnome-keyring.enable = true;
}
