{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.sops;
in
{
  options.pixos.bundles.sops = {
    enable = lib.mkEnableOption "sops-nix secrets bundle";

    defaultSopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../secrets/secrets.yaml;
      description = "Encrypted sops file that hosts pull secrets from by default.";
    };

    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sops-nix/key.txt";
      description = "Path on the host to the age private key used for decryption.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      defaultSopsFormat = "yaml";
      age = {
        keyFile = cfg.ageKeyFile;
        generateKey = false;
        sshKeyPaths = [ ];
      };
    };

    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];
  };
}
