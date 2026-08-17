{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.gui-misc;
in
{
  options.pixos.bundles.gui-misc.enable = lib.mkEnableOption "GUI misc tools bundle";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages =
          with pkgs;
          [
            localsend
            zotero
            audacity
            unbill-tauri
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [
            google-chrome
            shotcut
            obs-studio
            obsidian
            nextcloud-client
            udiskie
          ];
      }

      (lib.mkIf pkgs.stdenv.isLinux {
        services.gvfs.enable = true;

        home-manager.users.patrickli.services.udiskie = {
          enable = true;
          tray = "never";
        };

        home-manager.users.patrickli.services.nextcloud-client = {
          enable = true;
          startInBackground = true;
        };
      })
    ]
  );
}
