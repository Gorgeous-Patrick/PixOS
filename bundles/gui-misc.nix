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
        unbill-tauri
      ]
      # On macOS, Homebrew supplies Zotero to avoid compiling its Firefox runtime.
      ++ lib.optional (!pkgs.stdenv.hostPlatform.isDarwin) zotero;
  };
}
