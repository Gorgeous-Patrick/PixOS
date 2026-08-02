{
  config,
  lib,
  ...
}:

let
  cfg = config.pixos.bundles.ssh-keys;

  mkSecret = path: mode: {
    sopsFile = ../secrets/ssh.yaml;
    owner = cfg.user;
    inherit mode;
    inherit path;
  };
in
{
  options.pixos.bundles.ssh-keys = {
    enable = lib.mkEnableOption "SSH keys + config managed via sops-nix";

    user = lib.mkOption {
      type = lib.types.str;
      default = "patrickli";
      description = "User whose ~/.ssh is managed.";
    };

    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        SSH key names. Everything is decrypted from secrets/ssh.yaml at
        activation into ~/.ssh, owned by `user`:
          - ssh/<name>  → ~/.ssh/<name>      (private, mode 0600)
          - pub/<name>  → ~/.ssh/<name>.pub  (public,  mode 0644)
        and ssh_config  → ~/.ssh/config      (mode 0600).
      '';
    };
  };

  # Requires the sops bundle (sops-nix module + host age key) to be enabled.
  config = lib.mkIf cfg.enable {
    sops.secrets =
      lib.listToAttrs (
        lib.concatMap (name: [
          {
            name = "ssh/${name}";
            value = mkSecret "/home/${cfg.user}/.ssh/${name}" "0600";
          }
          {
            name = "pub/${name}";
            value = mkSecret "/home/${cfg.user}/.ssh/${name}.pub" "0644";
          }
        ]) cfg.keys
      )
      // {
        ssh_config = mkSecret "/home/${cfg.user}/.ssh/config" "0600";
      };
  };
}
