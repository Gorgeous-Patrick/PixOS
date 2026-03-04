{
  stdenvNoCC,
  lib,
  wallpkgs,
  tag ? null,
  name ? (if tag == null then "wallpapers-all" else "wallpapers-${tag}"),
}:

let
  # wallpkgs.wallpapers is an attrset -> list
  all = builtins.attrValues wallpkgs.wallpapers;

  filtered = if tag == null then all else builtins.filter (w: builtins.elem tag (w.tags or [ ])) all;

  # Best-effort: different wallpkgs entries may expose the file via different fields
  srcOf = w: (w.src or w.path or w.wallpaper or w.file or w);

in
stdenvNoCC.mkDerivation {
  pname = name;
  version = "1.0";
  dontUnpack = true;

  installPhase =
    let
      mkLink = i: w: ''
        ln -s ${lib.escapeShellArg (toString (srcOf w))} "$out/share/wallpapers/wall-${toString (i + 1)}"
      '';
    in
    ''
      mkdir -p "$out/share/wallpapers"
      ${lib.concatStringsSep "\n" (lib.imap0 mkLink filtered)}
    '';

  meta.description =
    if tag == null then
      "All wallpkgs wallpapers bundled into $out/share/wallpapers"
    else
      "wallpkgs wallpapers tagged '${tag}' bundled into $out/share/wallpapers";
}
