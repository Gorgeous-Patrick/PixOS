# profiles/macos/rootpkgs.nix
{ pkgs }:

pkgs.buildEnv {
  name = "pixos-macos";
  paths = with pkgs; [
    git
    curl
    ripgrep
    fd
    less
  ];
}
