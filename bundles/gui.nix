{ config, pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = [
    pkgs.kitty
    pkgs.google-chrome
    pkgs.vscode
    pkgs.wofi
  ];
}
