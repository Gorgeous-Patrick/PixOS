{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = [
    pkgs.kitty
    pkgs.google-chrome
    pkgs.vscode
  ];
}
