{
  config,
  lib,
  ...
}:

let
  cfg = config.pixos.bundles.claude-code;
in
{
  options.pixos.bundles.claude-code.enable = lib.mkEnableOption "Claude Code bundle";

  config = lib.mkIf cfg.enable {
    home-manager.users.patrickli.programs.claude-code.enable = true;
  };
}
