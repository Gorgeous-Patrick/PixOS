# profiles/minimal.nix
{ pkgs }:

pkgs.buildEnv {
  name = "pixos-minimal";
  paths = with pkgs; [
    git
    git-lfs
    curl
    ripgrep
    fd
    less
  ];
}
