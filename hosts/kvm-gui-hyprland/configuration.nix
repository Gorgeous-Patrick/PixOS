{ config, pkgs, ... }:
{
  imports = [
    ../kvm-minimal/configuration.nix
  ];

  # Enable Hyprland bundle (handles: programs.hyprland, greetd, xdg.portal, packages)
  pixos.bundles.hyprland.enable = true;
}
