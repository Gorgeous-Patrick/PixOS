{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.ssh-keys;
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${cfg.user}" else "/home/${cfg.user}";

  fixSshDirOwner = ''
    if [ -d ${homeDir}/.ssh ]; then
      chown ${cfg.user} ${homeDir}/.ssh
      chmod 700 ${homeDir}/.ssh
    fi
  '';

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
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        sops.secrets =
          lib.listToAttrs (
            lib.concatMap (name: [
              {
                name = "ssh/${name}";
                value = mkSecret "${homeDir}/.ssh/${name}" "0600";
              }
              {
                name = "pub/${name}";
                value = mkSecret "${homeDir}/.ssh/${name}.pub" "0644";
              }
            ]) cfg.keys
          )
          // {
            ssh_config = mkSecret "${homeDir}/.ssh/config" "0600";
          };
      }

      # sops-install-secrets writes the key/config symlinks into ~/.ssh and, in
      # doing so, resets that directory to root ownership. That stops the user
      # from creating ~/.ssh/known_hosts ("failed to add the host to the list of
      # known hosts"). Re-assert ownership of the directory itself after secrets
      # are set up — only the dir; the per-key symlinks resolve into /run/secrets
      # regardless and stay untouched.
      (lib.mkIf pkgs.stdenv.isDarwin {
        system.activationScripts.postActivation.text = lib.mkOrder 2000 fixSshDirOwner;
      })

      (lib.mkIf (!pkgs.stdenv.isDarwin) {
        system.activationScripts.fixSshDirOwner = lib.stringAfter [ "setupSecrets" ] fixSshDirOwner;
      })
    ]
  );
}
