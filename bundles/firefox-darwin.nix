# Darwin-only companion to bundles/firefox.nix.
#
# nixpkgs has no working Firefox.app on macOS, so the actual browser is
# installed via Homebrew while home-manager (in bundles/firefox.nix) manages
# only the profile. This lives in its own file — not in bundles/firefox.nix —
# because `homebrew.*` is declared only by nix-darwin, so a module that sets it
# cannot be evaluated on NixOS. mkDarwinHost is the only builder that imports it.
{ config, lib, ... }:
{
  config = lib.mkIf config.pixos.bundles.firefox.enable {
    homebrew.casks = [ "firefox" ];

    home-manager.users.patrickli.programs.firefox = {
      # Homebrew provides Firefox.app on Darwin; Home Manager manages only the
      # profile that Firefox.app reads.
      package = lib.mkForce null;
      configPath = lib.mkForce "Library/Application Support/Firefox";
    };
  };
}
