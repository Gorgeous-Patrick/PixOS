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
  options.pixos.bundles.gui-misc.enable = lib.mkEnableOption "Ollama bundle";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ollama
    ];
    services.ollama = {
      enable = true;
    };
  };
}
