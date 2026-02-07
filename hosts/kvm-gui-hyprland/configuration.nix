{ config, pkgs, ... }:
{
  imports = [
    ../kvm-minimal/configuration.nix
  ];
}
