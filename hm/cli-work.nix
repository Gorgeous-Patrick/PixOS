{ config, pkgs, ... }:
{
    imports = [
        ../bundles/cli-base.nix
        ../bundles/programming.nix
        ../applications/nvim/nvim.nix
    ];
}
