{
	home-manager.users.patrickli = {config, pkgs, ... }: {
        /* The home.stateVersion option does not have a default and must be set */
        home.stateVersion = "24.11";
        /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */
        home.packages = [pkgs.cargo pkgs.gcc14 pkgs.yarn pkgs.ranger pkgs.thefuck pkgs.nodejs pkgs.lazygit pkgs.bat];
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
            v = "nvim";
            r = "ranger";
            update = "sudo nixos-rebuild switch";
            cat = "bat";
          };
        oh-my-zsh = {
                enable = true;
                plugins = [ "git" "thefuck" ];
                theme = "robbyrussell";
              };
        };
        programs.neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;
            defaultEditor = true;
        };
        xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink ./nvim;
	};
}
