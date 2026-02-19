{ pkgs, lib, ... }:
{
  imports = [ ./minimal.nix ];

  home.homeDirectory = lib.mkForce "/Users/patrickli";
  home.packages = lib.mkForce (import ../profiles/macos/hm/packages.nix { inherit pkgs; });
}
