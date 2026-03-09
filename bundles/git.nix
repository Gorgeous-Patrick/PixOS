{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.git;
in
{
  options.pixos.bundles.git.enable = lib.mkEnableOption "Git bundle";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      gh
      delta
      lazygit
    ];

    home-manager.users.patrickli =
      { pkgs, ... }:
      {
        programs.git = {
          enable = true;
          lfs.enable = true;
          userName = "Patrick Li";
          userEmail = "baichuanli@yahoo.com";
          extraConfig = {
            pull.rebase = true;
            core.pager = "delta";
            interactive.diffFilter = "delta --color-only";
            delta = {
              navigate = true;
              side-by-side = true;
              line-numbers = true;
            };
            merge.conflictstyle = "diff3";
            diff.colorMoved = "default";
          };
        };
      };
  };
}
