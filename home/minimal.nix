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

    clipboard.register = "unnamedplus";

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 300;
    };

  };

  programs.git = {
    enable = true;
    userName = "Patrick Li";
    userEmail = "baichuanli@yahoo.com";
  };
}
