{ pkgs, ... }:
{
  # Ozone/Wayland fixes for Electron apps with blurry text
  # These override the default .desktop files to add proper Wayland flags
  #
  # References:
  # - https://wiki.archlinux.org/title/Discord
  # - https://wiki.archlinux.org/title/Steam/Troubleshooting
  # - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer

  xdg.desktopEntries = {
    # Discord with Ozone Wayland fix
    # Discord removed flags file support, must use desktop entry override
    discord = {
      name = "Discord";
      comment = "All-in-one voice and text chat";
      icon = "discord";
      exec = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-webrtc-pipewire-capturer";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/discord" ];
    };

    # Slack with Ozone Wayland fix
    slack = {
      name = "Slack";
      comment = "Slack Desktop";
      icon = "slack";
      exec = "slack --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --ozone-platform=wayland";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/slack" ];
    };

    # Spotify with Ozone Wayland fix
    spotify = {
      name = "Spotify";
      comment = "Music Player";
      icon = "spotify-client";
      exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland";
      terminal = false;
      type = "Application";
      categories = [
        "Audio"
        "Music"
        "Player"
        "AudioVideo"
      ];
      mimeType = [ "x-scheme-handler/spotify" ];
    };

    # Obsidian with Ozone Wayland fix
    obsidian = {
      name = "Obsidian";
      comment = "Knowledge base";
      icon = "obsidian";
      exec = "obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland";
      terminal = false;
      type = "Application";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
    };

    # 1Password with Ozone Wayland fix
    "1password" = {
      name = "1Password";
      comment = "Password Manager";
      icon = "1password";
      exec = "1password --enable-features=UseOzonePlatform --ozone-platform=wayland";
      terminal = false;
      type = "Application";
      categories = [ "Utility" ];
    };
  };

  # Steam scaling fix for HiDPI/Wayland
  # Steam runs via XWayland and needs explicit scaling factor
  # Adjust STEAM_FORCE_DESKTOPUI_SCALING to match your display scale
  home.sessionVariables = {
    # Force Steam UI scaling (1.0 = 100%, 1.5 = 150%, 2.0 = 200%)
    # Set to 1.0 for no scaling, adjust if using fractional scaling
    STEAM_FORCE_DESKTOPUI_SCALING = "1.0";
  };
}
