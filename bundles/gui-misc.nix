{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.git;
in
{
  options.pixos.bundles.gui-misc.enable = lib.mkEnableOption "GUI misc tools bundle";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      localsend
      zotero
      shotcut
      obs-studio
    ];
  };
}
