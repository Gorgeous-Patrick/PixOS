{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.concord;
  homeDir = if pkgs.stdenv.isDarwin then "/Users/patrickli" else "/home/patrickli";
  userGroup = if pkgs.stdenv.isDarwin then "staff" else "users";
in
{
  options.pixos.bundles.concord.enable =
    lib.mkEnableOption "Concord TUI Discord client (requires sops with a `discord_token` secret)";

  config = lib.mkIf cfg.enable {
    sops.secrets.discord_token = {
      owner = "patrickli";
      group = userGroup;
      mode = "0400";
    };

    sops.templates."concord-credentials.toml" = {
      owner = "patrickli";
      group = userGroup;
      mode = "0600";
      path = "${homeDir}/.local/state/concord/credentials.toml";
      content = ''
        selected_account = "default"

        [[accounts]]
        id = "default"
        token = "${config.sops.placeholder.discord_token}"
      '';
    };

    environment.systemPackages = [ pkgs.concord-tui ];

    home-manager.users.patrickli = {
      xdg.configFile."concord/config.toml".text = ''
        [credentials]
        store = "plain"
      '';
    };
  };
}
