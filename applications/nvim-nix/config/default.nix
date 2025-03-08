{ config, pkgs, lib, ... }:
{
  # Import all your configuration modules here
  imports = [ ./plugins.nix ./keymaps.nix ];
  extraConfigLua = (builtins.readFile ./init.lua);
}
