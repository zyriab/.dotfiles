{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    languagePacks = [
      "en-US"
      "fr"
      "es-ES"
    ];
  };

  environment.systemPackages = with pkgs; [
    chromium
  ];
}
