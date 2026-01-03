{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;

    # Extensions (installed via policy - user cannot remove)
    # Format: extension-id or extension-id;update-url
    extensions = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "kgaddahbbpflkifbmkhindpbafggbobh" # Prod
      "oghkljobbhapacbahlneolfclkniiami" # Tab Session Manager
      "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    ];

    # Command line args
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };

  # Chromium policies for settings that can't be set via home-manager
  # These are applied system-wide via managed policies
  xdg.configFile."chromium/policies/managed/settings.json".text = builtins.toJSON {
    # Password and autofill
    PasswordManagerEnabled = false;
    AutofillCreditCardEnabled = false;
    AutofillAddressEnabled = false;

    # Performance
    MemorySaverModeSavings = 1; # 0=off, 1=balanced, 2=maximum

    # Appearance
    BookmarkBarEnabled = false;
    ShowHomeButton = false;

    # Privacy/Security
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Google";
    DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";

    # Startup
    RestoreOnStartup = 5; # 5 = Open New Tab page

    # Translation
    TranslateEnabled = true;
    # Languages to never translate
    TranslateBlockedLanguages = [
      "fr"
      "es"
    ];

    # Hardware acceleration
    HardwareAccelerationModeEnabled = true;

    # Extensions allowed in incognito (by ID)
    ExtensionAllowedTypes = [ "extension" ];
  };

  # Chromium preferences (user-level settings)
  # Note: Some of these may be overwritten by the browser on first run
  xdg.configFile."chromium/Default/Preferences".text = builtins.toJSON {
    # Spellcheck
    spellcheck = {
      dictionaries = [
        "en-US"
        "fr"
        "es"
      ];
      use_spelling_service = false;
    };

    # Browser settings
    browser = {
      show_home_button = false;
      enable_spellchecking = true;
    };

    # Extensions in incognito - needs to be set manually per extension
    # This is just a hint, actual setting requires user interaction

    # Accessibility
    accessibility = {
      speak_page_summary_on_load = false;
    };

    # Download settings
    download = {
      prompt_for_download = true;
    };
  };
}
