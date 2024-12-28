{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.patrickli = {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "24.11";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */
    home.packages = [pkgs.neovim pkgs.git];
    programs.git = {
    	enable = true;
	userName = "Gorgeous-Patrick";
	userEmail = "baichuanli@yahoo.com";
	};
    programs.zsh = {
	  enable = true;
	  enableCompletion = true;
	  shellAliases = {
	    ll = "ls -l";
	    update = "sudo nixos-rebuild switch";
	  };
	};
  };
}
