{
  home-manager.users.patrickli =
    { config, pkgs, ... }:
    {
        imports = [
            ../bundles/cli-base.nix
            ../applications/nvim/nvim.nix
        ];
    };
}
