{ config, pkgs, ... }:

{
  imports = [
    ./minimal.nix
  ];

  # Enable Hyprland bundle
  pixos.bundles.hyprland.enable = true;
  pixos.bundles.gui-misc.enable = true;
  pixos.bundles.firefox.enable = true;

  # Additional GUI packages not in the bundle
  environment.systemPackages = with pkgs; [
    dbeaver-bin
    google-chrome
    shotcut
    obs-studio
    obsidian
    nextcloud-client
    udiskie
  ];

  services.gvfs.enable = true;

  home-manager.users.patrickli.services.udiskie = {
    enable = true;
    tray = "never";
  };

  home-manager.users.patrickli.services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
