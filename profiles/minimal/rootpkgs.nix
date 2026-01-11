# profiles/minimal.nix
{ pkgs }:

pkgs.buildEnv {
  name = "pixos-minimal";
  paths = with pkgs; [
    git
    curl
    ripgrep
    fd
    less
    neovim
    zsh
  ];
}
