{ pkgs, ... }:

{
  imports = [
    ./minimal.nix
  ];

  # Hyprland home-manager config is handled by the bundle
  # Additional GUI programs
  programs.discord.enable = true;
}
