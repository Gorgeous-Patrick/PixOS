{ config, pkgs, ... }:
{
    imports = [
        ../bundles/cli-base.nix
        ../applications/nvim-nix/nvim.nix
    ];
}
