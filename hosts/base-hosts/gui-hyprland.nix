{ config, pkgs, ... }:

{
  imports = [
    ./minimal.nix
  ];

  # Enable Hyprland bundle
  pixos.bundles.hyprland.enable = true;
  pixos.bundles.gui-misc.enable = true;

  # Additional GUI packages not in the bundle
  environment.systemPackages = with pkgs; [
    dbeaver-bin
  ];
}
