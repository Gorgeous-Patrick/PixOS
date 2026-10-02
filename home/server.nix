{ pkgs, ... }:

{
  home.username = "patrickli";
  home.homeDirectory = "/home/patrickli";
  home.stateVersion = "26.05";
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  home.packages = [
    pkgs.yazi
    pkgs.herdr
  ];

  programs.home-manager.enable = true;
  programs.zellij.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
  programs.direnv.nix-direnv.enable = true;
}
