{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../base-hosts/gui-hyprland.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";

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
    overskride
    networkmanagerapplet
    openssl
    telegram-desktop
    stdenv.cc.cc.lib
    nix-index
    direnv
  ];
}
