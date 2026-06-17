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
  nixfmt-rfc-style
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
  python313
  pre-commit
  devenv
]
++ (if charcoal != null then [ charcoal ] else [ ])
