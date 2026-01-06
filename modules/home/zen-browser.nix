{
  inputs,
  pkgs,
  lib,
  firefox-addons,
  ...
}:
let
  addons = firefox-addons;

  # Custom addon not in rycee's collection
  prod = pkgs.fetchFirefoxAddon {
    name = "prod";
    url = "https://addons.mozilla.org/firefox/downloads/latest/prodextension/latest.xpi";
    hash = "sha256-u8CZ0fn1EmBnwVyd8T7Y81cUnClLePBvcCMnZAi76Nk=";
  };
in
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  # Force overwrite existing profiles.ini
  home.file.".zen/profiles.ini".force = true;

  # Add zen to 1Password allowed browsers: echo "zen" | sudo tee -a /etc/1password/custom_allowed_browsers
  programs.zen-browser = {
    enable = true;

    policies = {
      # Disable built-in password manager (using 1Password)
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;

      Homepage = {
        StartPage = "none";
      };

      # Hardware acceleration
      HardwareAcceleration = true;

      # Bookmarks bar
      DisplayBookmarksToolbar = "never";

      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles.default = {
      isDefault = true;

      extensions.packages =
        (with addons; [
          onepassword-password-manager
          darkreader
          ublock-origin
          vimium
          react-devtools
          tab-session-manager
        ])
        ++ [ prod ];

      search = {
        default = "google";
        force = true;
        engines = {
          bing.metaData.hidden = true;
          amazon.metaData.hidden = true;
          ebay.metaData.hidden = true;
        };
      };

      settings = {
        # Restore previous session on startup
        "browser.startup.page" = 3;

        # Spell check
        "spellchecker.dictionary" = "en-US,fr,es-ES";
        "layout.spellcheckDefault" = 1;

        # Language settings
        "intl.accept_languages" = "en-US,en,fr,es";

        # Dark mode
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;

        # Performance - memory saver equivalent
        "browser.tabs.unloadOnLowMemory" = true;

        # Disable password saving
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;

        # Disable credit card autofill
        "extensions.formautofill.creditCards.enabled" = false;

        # Home button disabled
        "browser.showHomeButton" = false;

        # Translation - never translate French or Spanish
        "browser.translations.neverTranslateLanguages" = "fr,es";

        # Hardware acceleration
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;
      };
    };
  };
}
