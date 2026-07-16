# Full TeX Live distribution + a PDF viewer for the editor to drive.
#
# The Neovim-side LaTeX support (vimtex, texlab, treesitter) lives in
# bundles/nvim.nix and is present on every nvim host regardless — this bundle
# provides the actual toolchain (latexmk, biber, every CTAN package) that makes
# compilation and the LSP work. vimtex is configured to use zathura on Linux;
# on Darwin it falls back to `open` (Preview/Skim), so no viewer is added there.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.latex;
in
{
  options.pixos.bundles.latex.enable =
    lib.mkEnableOption "LaTeX toolchain (full TeX Live, latexmk, biber) + PDF viewer";

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      # scheme-full: latexmk, biber, and every CTAN package are included.
      [ pkgs.texliveFull ]
      # vimtex's zathura view_method needs zathura; Linux GUI hosts only.
      ++ lib.optional pkgs.stdenv.isLinux pkgs.zathura;
  };
}
