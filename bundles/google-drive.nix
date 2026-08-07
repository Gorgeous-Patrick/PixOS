{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.google-drive;

  mountScript = pkgs.writeShellScript "rclone-google-drive-mount" ''
    set -euo pipefail

    mountpoint="$HOME/${cfg.mountPoint}"
    cache_dir="$HOME/${cfg.cacheDir}"
    runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"
    rc_socket="$runtime_dir/rclone-google-drive.sock"

    mkdir -p "$mountpoint" "$cache_dir"
    rm -f "$rc_socket"

    exec ${pkgs.rclone}/bin/rclone mount ${lib.escapeShellArg "${cfg.remoteName}:"} "$mountpoint" \
      --config "$HOME/.config/rclone/rclone.conf" \
      --cache-dir "$cache_dir" \
      --rc \
      --rc-addr "unix://$rc_socket" \
      --rc-enable-metrics \
      --vfs-cache-mode full \
      --vfs-cache-max-size ${lib.escapeShellArg cfg.cacheMaxSize} \
      --vfs-cache-max-age ${lib.escapeShellArg cfg.cacheMaxAge} \
      --vfs-write-back ${lib.escapeShellArg cfg.writeBack} \
      --buffer-size ${lib.escapeShellArg cfg.bufferSize} \
      --dir-cache-time ${lib.escapeShellArg cfg.dirCacheTime} \
      --poll-interval ${lib.escapeShellArg cfg.pollInterval} \
      --umask 022 \
      --log-level INFO
  '';

  unmountScript = pkgs.writeShellScript "rclone-google-drive-unmount" ''
    /run/wrappers/bin/fusermount3 -uz "$HOME/${cfg.mountPoint}" || true
  '';
in
{
  options.pixos.bundles.google-drive = {
    enable = lib.mkEnableOption "cached Google Drive mount";

    remoteName = lib.mkOption {
      type = lib.types.str;
      default = "gdrive";
      description = "Name of the rclone Google Drive remote, without a trailing colon.";
    };

    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "GoogleDrive";
      description = "Mount point relative to the user's home directory.";
    };

    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = ".cache/rclone/google-drive";
      description = "Persistent VFS cache directory relative to the user's home directory.";
    };

    cacheMaxSize = lib.mkOption {
      type = lib.types.str;
      default = "100G";
      description = "Maximum local disk space used by the rclone VFS cache.";
    };

    cacheMaxAge = lib.mkOption {
      type = lib.types.str;
      default = "720h";
      description = "How long cached file data may remain locally before eviction.";
    };

    writeBack = lib.mkOption {
      type = lib.types.str;
      default = "15m";
      description = "Delay before closed, changed files are uploaded to Google Drive.";
    };

    bufferSize = lib.mkOption {
      type = lib.types.str;
      default = "128M";
      description = "In-memory read buffer per open file.";
    };

    dirCacheTime = lib.mkOption {
      type = lib.types.str;
      default = "72h";
      description = "How long directory listings are cached in memory.";
    };

    pollInterval = lib.mkOption {
      type = lib.types.str;
      default = "1m";
      description = "How often rclone polls Google Drive for remote-side changes.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [
          pkgs.rclone
        ];

        systemd.tmpfiles.rules = [
          "d /home/patrickli/.config/rclone 0700 patrickli users -"
        ];

        home-manager.users.patrickli = {
          home.packages = [
            pkgs.rclone
          ];

          systemd.user.services.rclone-google-drive = {
            Unit = {
              Description = "Cached Google Drive mount";
              Documentation = "https://rclone.org/drive/";
              Wants = [ "network-online.target" ];
              After = [ "network-online.target" ];
              ConditionPathExists = "%h/.config/rclone/rclone.conf";
            };

            Service = {
              Type = "notify";
              ExecStart = "${mountScript}";
              ExecStop = "${unmountScript}";
              Restart = "on-failure";
              RestartSec = "30s";
            };

            Install.WantedBy = [ "default.target" ];
          };
        };
      }

      (lib.mkIf (options ? sops.secrets) {
        sops.secrets.rclone_config = {
          sopsFile = ../secrets/rclone.yaml;
          key = "rclone_config";
          owner = "patrickli";
          mode = "0600";
          path = "/home/patrickli/.config/rclone/rclone.conf";
        };
      })
    ]
  );
}
