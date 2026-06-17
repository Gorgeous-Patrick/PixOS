{
  config,
  lib,
  pkgs,
  firefoxAddons ? null,
  ...
}:

let
  cfg = config.pixos.bundles.firefox;

  addons =
    if firefoxAddons == null then
      [ ]
    else
      with firefoxAddons; [
        ublock-origin
        bitwarden
        darkreader
      ];

  # Moderate hardening: kill telemetry / sponsored content / studies / Pocket,
  # leave DRM, Sync, and modern web features intact.
  ffSettings = {
    # Telemetry & data reporting
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.coverage.opt-out" = true;
    "toolkit.coverage.endpoint.base" = "";

    # Studies / experiments
    "app.shield.optoutstudies.enabled" = false;
    "app.normandy.enabled" = false;
    "app.normandy.api_url" = "";

    # Crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;

    # Pocket
    "extensions.pocket.enabled" = false;
    "extensions.pocket.api" = "";
    "extensions.pocket.site" = "";

    # New-tab sponsored / Activity Stream noise
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;

    # URL-bar suggestions to remote services
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.quicksuggest.enabled" = false;

    # First-run / what's-new spam
    "browser.aboutwelcome.enabled" = false;
    "browser.startup.homepage_override.mstone" = "ignore";
    "startup.homepage_welcome_url" = "";
    "startup.homepage_welcome_url.additional" = "";
    "startup.homepage_override_url" = "";

    # Disable Firefox Account / Sync entirely — no sign-in prompts, hides
    # Sync UI in preferences, suppresses the "Sign in to sync" toolbar/menu.
    "identity.fxaccounts.enabled" = false;
    "identity.fxaccounts.toolbar.enabled" = false;
    "identity.fxaccounts.pairing.enabled" = false;
    "services.sync.engine.addons" = false;
    "services.sync.engine.bookmarks" = false;
    "services.sync.engine.history" = false;
    "services.sync.engine.passwords" = false;
    "services.sync.engine.prefs" = false;
    "services.sync.engine.tabs" = false;
    "browser.tabs.firefox-view" = false;

    # Privacy defaults
    "browser.contentblocking.category" = "strict";
    "privacy.donottrackheader.enabled" = true;
    "privacy.globalprivacycontrol.enabled" = true;

    # Bitwarden handles passwords; turn off built-in saver
    "signon.rememberSignons" = false;
    "browser.formfill.enable" = false;

    # UX
    "browser.search.suggest.enabled" = true;
    "browser.urlbar.suggest.searches" = true;
    "browser.warnOnQuit" = false;
    "browser.tabs.warnOnClose" = false;
    "browser.toolbars.bookmarks.visibility" = "newtab";
    "browser.uidensity" = 1; # compact
  };

  mkHmFirefox = isDarwin: {
    programs.firefox = {
      enable = true;
      # nixpkgs has no working Firefox.app on Darwin — install via Homebrew
      # below and let home-manager only manage the profile directory.
      package = if isDarwin then null else pkgs.firefox;

      profiles.default = {
        id = 0;
        isDefault = true;
        settings = ffSettings;
        extensions.packages = addons;

        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          order = [ "ddg" "google" ];
        };
      };
    };
  };
in
{
  options.pixos.bundles.firefox.enable = lib.mkEnableOption "Firefox bundle";

  # NOTE: the Firefox.app bundle on macOS is installed via Homebrew. That
  # piece lives in a small darwin-only module in flake.nix, because the
  # `homebrew.*` option is declared only by nix-darwin and conditioning on
  # `pkgs.stdenv.isDarwin` here would create a config <-> pkgs cycle.
  config = lib.mkIf cfg.enable {
    home-manager.users.patrickli = mkHmFirefox pkgs.stdenv.isDarwin;
  };
}
