{ config, pkgs, ... }:
{
  imports = [
    ../bundles/cli-base.nix
    ../bundles/programming.nix
    ../bundles/db.nix
  ];
}
