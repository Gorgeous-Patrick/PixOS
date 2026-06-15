{
  pkgs,
  lib,
  charcoalPkg ? null,
  ...
}:
{
  imports = [ ./minimal.nix ];

  home.homeDirectory = lib.mkForce "/Users/patrickli";
  # Normal (mergeable) assignment so bundle-provided packages (e.g. the nixvim
  # wrapped neovim) are included alongside the macOS list. minimal.nix no longer
  # contributes a package list on Darwin, so no mkForce is needed here.
  home.packages = import ../profiles/macos/hm/packages.nix {
    inherit pkgs;
    charcoal = charcoalPkg;
  };
}
