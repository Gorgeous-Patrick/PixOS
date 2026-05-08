{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.hyprland;
in
{
  options.pixos.bundles.niri.enable = lib.mkEnableOption "niri bundle";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      niri
    ];
  };
}
