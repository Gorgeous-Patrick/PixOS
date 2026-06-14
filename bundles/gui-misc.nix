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

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        localsend
        zotero
        audacity
        qutebrowser
        telegram-desktop
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        unbill-tauri
        google-chrome
        shotcut
        obs-studio
        obsidian
      ];
  };
}
