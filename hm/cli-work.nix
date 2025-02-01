{
  home-manager.users.patrickli =
    { config, pkgs, ... }:
    {
        imports = [
            ../bundles/cli-base.nix
            ../bundles/programming.nix
            ../applications/nvim/nvim.nix
        ];
    };
}
