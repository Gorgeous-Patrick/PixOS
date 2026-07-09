{
  config,
  pkgs,
  wallpkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../base-hosts/gui-hyprland.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";

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
  pixos.bundles.hyprland.wallpaperPath = "${wallpkgs}/wallpapers/catppuccin";

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
    stdenv.cc.cc.lib
    nix-index
    direnv
    pulsemixer
    (pkgs.writeShellScriptBin "alt-server" ''
      export LD_LIBRARY_PATH="${pkgs.avahi-compat}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec ${pkgs.altserver-linux}/bin/alt-server "$@"
    '')
  ];
  pixos.bundles.fcitx5.enable = true;
  pixos.bundles.ollama.enable = true;
  pixos.bundles.niri.enable = true;
  pixos.bundles.sops.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  home-manager.users.patrickli = {
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
