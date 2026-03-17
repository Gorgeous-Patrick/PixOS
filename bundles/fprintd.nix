{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.fprintd;
in
{
  options.pixos.bundles.fprintd.enable = lib.mkEnableOption "Finger print module";

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;
  };
}
