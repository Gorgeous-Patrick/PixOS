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
  options.pixos.bundles.web-dev.enable = lib.mkEnableOption "Web dev bundle";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      httpie
      jq
    ];
  };
}
