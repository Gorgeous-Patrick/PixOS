{ config, pkgs, ... }:
{
    imports = [
        ../bundles/cli-base.nix
        ../bundles/programming.nix
        ../bundles/db.nix
        ../bundles/gui.nix
        ../applications/nvim-nix/nvim.nix
        ../applications/hyprland/hyprland.nix
    ];
}
