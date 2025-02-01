{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
  xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink ./config;
}
