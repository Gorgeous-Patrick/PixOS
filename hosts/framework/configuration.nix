{
  config,
  pkgs,
  ...
}:

let
  kdenliveSpeechPython = pkgs.python3.withPackages (
    pythonPackages: with pythonPackages; [
      openai-whisper
      pip
      requests
      srt
    ]
  );

  kdenliveWhisperBaseModel = pkgs.fetchurl {
    url = "https://openaipublic.azureedge.net/main/whisper/models/ed3a0b6b1c0edf879ad9b11b1af5a0e6ab5db9205f891f668f8b0e6c6326e34e/base.pt";
    hash = "sha256-7ToLaxwO34ea2bEbGvWg5qtduSBfiR9mj4sObGMm404=";
  };

  kdenliveWithSpeech = pkgs.symlinkJoin {
    name = "kdenlive-with-rnnoise-and-whisper";
    paths = [ pkgs.kdePackages.kdenlive ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/kdenlive $out/bin/kdenlive_render
      makeWrapper ${pkgs.kdePackages.kdenlive}/bin/kdenlive $out/bin/kdenlive \
        --set LADSPA_PATH "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa" \
        --prefix PATH : "${pkgs.lib.makeBinPath [ kdenliveSpeechPython ]}"
      makeWrapper ${pkgs.kdePackages.kdenlive}/bin/kdenlive_render $out/bin/kdenlive_render \
        --set LADSPA_PATH "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa" \
        --prefix PATH : "${pkgs.lib.makeBinPath [ kdenliveSpeechPython ]}"
    '';
  };

  kdenliveDownloadWhisperModel = pkgs.writeShellScriptBin "kdenlive-download-whisper-model" ''
    set -euo pipefail

    model="''${1:-base}"
    cache_root="''${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_CACHE_HOME="$cache_root"

    exec ${kdenliveSpeechPython}/bin/python3 -c '
    import os
    import sys
    import whisper

    model = sys.argv[1]
    if model not in whisper._MODELS:
        available = ", ".join(whisper.available_models())
        raise SystemExit(f"Unknown Whisper model: {model}\nAvailable models: {available}")

    root = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "whisper")
    os.makedirs(root, exist_ok=True)
    url = whisper._MODELS[model]
    target = os.path.join(root, os.path.basename(url))
    print(f"Downloading Whisper model {model} to {target}")
    whisper._download(url, root, False)
    ' "$model"
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../base-hosts/gui-hyprland.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PermitRootLogin = "no";
  };

  networking.firewall.allowedTCPPorts = [
    3000 # generic web dev
    3001
    3002
    4000 # Phoenix / misc
    5173 # Vite
    8000 # Trunk
    8080 # API servers
    8888 # Jupyter
    9000 # misc
  ];

  # ── Hyprland bundle config ────────────────────────────────────
  pixos.bundles.hyprland.monitors = [
    "DP-3, 3440x1440, 0x0, 1"
    "eDP-1, 2880x1920, 0x1440, 2"
    "DP-4, 1920x1080, 3440x0, 1, transform, 1"
  ];
  pixos.bundles.hyprland.wallpaperPath = "${pkgs.wallpkgs}/wallpapers/catppuccin";

  # ── Framework-specific ─────────────────────────────────────────

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  # ── AltServer ────────────────────────────────────────────────
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.usbmuxd.enable = true;

  virtualisation.oci-containers.containers.anisette = {
    image = "dadoum/anisette-v3-server";
    ports = [ "6969:6969" ];
    autoStart = true;
  };

  systemd.services.altserver = {
    description = "AltServer-Linux";
    after = [
      "network.target"
      "avahi-daemon.service"
      "docker-anisette.service"
    ];
    wants = [
      "avahi-daemon.service"
      "docker-anisette.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.altserver-linux}/bin/alt-server";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "LD_LIBRARY_PATH=${pkgs.avahi-compat}/lib"
        "ALTSERVER_ANISETTE_SERVER=http://127.0.0.1:6969"
      ];
    };
  };

  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org https://unbill.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= unbill.cachix.org-1:157H1n8eC+rAITRruhXXuS5CUWvSgUIhkzRIbp+AKng=
  '';
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    warp-terminal
    overskride
    networkmanagerapplet
    openssl
    telegram-desktop
    kdenliveWithSpeech
    kdenliveSpeechPython
    kdenliveDownloadWhisperModel
    rnnoise-plugin.ladspa
    stdenv.cc.cc.lib
    nix-index
    direnv
    pulsemixer
    (pkgs.writeShellScriptBin "alt-server" ''
      export LD_LIBRARY_PATH="${pkgs.avahi-compat}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec ${pkgs.altserver-linux}/bin/alt-server "$@"
    '')
  ];

  environment.sessionVariables = {
    LADSPA_PATH = "/run/current-system/sw/lib/ladspa";
  };

  pixos.bundles.fcitx5.enable = true;
  pixos.bundles.davinci-resolve.enable = true;
  pixos.bundles.google-drive.enable = true;
  pixos.bundles.ollama.enable = false;
  pixos.bundles.niri.enable = true;
  pixos.bundles.sops.enable = true;

  sops.secrets.anthropic_api_key = {
    owner = "patrickli";
    mode = "0400";
  };

  # SSH identity from sops: private keys → ~/.ssh/<name> (0600, encrypted),
  # ~/.ssh/config → decrypted from secrets/ssh.yaml (has IPs, so encrypted),
  # and ~/.ssh/<name>.pub → deployed plaintext from files/ssh-pub/.
  pixos.bundles.ssh-keys.enable = true;
  pixos.bundles.ssh-keys.keys = [
    "ag281"
    "ag281-new"
    "aliyun"
    "aur"
    "baixing"
    "bane"
    "clarity"
    "eecs587"
    "github"
    "gitlab_eecs"
    "hosico"
    "hosteons"
    "id_ecdsa"
    "id_rsa"
    "patrickli.one"
    "patrickliserver"
    "sfocs"
    "sfocs-git"
    "unbill-aur"
    "wt_blade"
  ];

  pixos.bundles.concord.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  home-manager.users.patrickli =
    { config, lib, ... }:
    {
      home.file.".cache/whisper/base.pt".source = kdenliveWhisperBaseModel;

      home.activation.configureKdenliveSpeech = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.coreutils}/bin/mkdir -p "${config.xdg.configHome}"
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "${config.xdg.configHome}/kdenliverc" --group speech --key speech_system_python true
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "${config.xdg.configHome}/kdenliverc" --group speech --key speech_system_python_path "${kdenliveSpeechPython}/bin/python3"
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "${config.xdg.configHome}/kdenliverc" --group speech --key speechEngine whisper
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "${config.xdg.configHome}/kdenliverc" --group speech --key whisperModel base
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "${config.xdg.configHome}/kdenliverc" --group speech --key whisperModelFolder "${config.home.homeDirectory}/.cache/whisper"
      '';

      systemd.user.services.unbill-daemon = {
        Unit.Description = "Unbill daemon";
        Service = {
          ExecStart = "${pkgs.unbill-daemon}/bin/unbill-daemon";
          Restart = "always";
          Environment = [ "UNBILL_SYNC_INTERVAL_SECS=3600" ];
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
