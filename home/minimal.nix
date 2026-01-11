{ pkgs, ... }:
{
  home.username = "patrickli";
  home.homeDirectory = "/home/patrickli";
  home.stateVersion = "24.11";

  home.packages =
    import ../profiles/minimal/hm/packages.nix { inherit pkgs; };

  programs.home-manager.enable = true;
  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Patrick Li";
    userEmail = "baichuanli@yahoo.com";
  };
}
