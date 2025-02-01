{ config, pkgs, ... }:
{
    imports = [
        ../bundles/cli-base.nix
        ../applications/nvim/nvim.nix
    ];
}
