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
  users.users.patrickli.extraGroups = [ "docker" ];

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ zlib ];

  virtualisation.docker.enable = true;

  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

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
