{
  home-manager.users.patrickli =
    { config, pkgs, ... }:
    {
        imports = [./applications/cli-base.nix
        ./applications/nvim/nvim.nix];
    };
}
