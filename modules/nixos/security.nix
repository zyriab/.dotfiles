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

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
