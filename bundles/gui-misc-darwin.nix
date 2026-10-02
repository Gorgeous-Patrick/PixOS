# Darwin-only companion to gui-misc.nix; Homebrew installs the prebuilt app.
{ config, lib, ... }:
{
  config = lib.mkIf config.pixos.bundles.gui-misc.enable {
    homebrew.casks = [ "zotero" ];
  };
}
