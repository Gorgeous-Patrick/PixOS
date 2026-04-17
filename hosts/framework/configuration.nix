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

  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
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
  ];
  pixos.bundles.ollama.enable = true;
}
