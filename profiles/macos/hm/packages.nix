{
  pkgs,
  charcoal ? null,
}:

with pkgs;
[
  cachix
  ranger
  lazygit
  bat
  nixfmt-rfc-style
  treefmt
  eza
  htop
  neofetch
  tmux
  cloc
  cargo
  rustc
  nodejs
  gcc
  python313
  pre-commit
  devenv
  neovim
]
++ (if charcoal != null then [ charcoal ] else [ ])
