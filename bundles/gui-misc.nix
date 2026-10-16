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
        audacity
      ]
      # On macOS, Homebrew supplies Zotero and the Unbill desktop app.
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        zotero
        unbill-tauri
      ];
  };
}
