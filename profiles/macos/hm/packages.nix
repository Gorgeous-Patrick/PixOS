{
  pkgs,
  charcoal ? null,
}:

with pkgs;
[
  cachix
  ranger
  yazi
  lazygit
  bat
  nixfmt
  treefmt
  eza
  htop
  fastfetch
  tmux
  cloc
  cargo
  rustc
  nodejs
  gcc
  python314FreeThreading
  pre-commit
  devenv
  codex
  claude-code
]
++ (if charcoal != null then [ charcoal ] else [ ])
