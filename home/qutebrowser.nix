{
  pkgs,
  lib,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;

  dmenu-wrapper = pkgs.writeShellScriptBin "qb-dmenu" (
    if isDarwin then
      ''exec ${pkgs.choose-gui}/bin/choose''
    else
      ''exec ${pkgs.rofi}/bin/rofi -dmenu -i -p Bitwarden''
  );

  password-prompt-wrapper = pkgs.writeShellScriptBin "qb-password-prompt" (
    if isDarwin then
      ''exec /usr/bin/osascript -e 'display dialog "Bitwarden Master Password" default answer "" with hidden answer' -e 'text returned of result' ''
    else
      ''exec ${pkgs.rofi}/bin/rofi -dmenu -p "Master Password" -password -lines 0''
  );

  pythonWithDeps = pkgs.python3.withPackages (ps: [ ps.tldextract ps.pyperclip ]);

  qute-bitwarden-src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/qutebrowser/qutebrowser/v3.7.0/misc/userscripts/qute-bitwarden";
    sha256 = "092ayjkhzfka4d2vl05y9c5zwnf0lkn8gxairl1kgcn0wwhz0y50";
  };

  # macOS shim for keyctl (Linux kernel keyring).
  # Stores the BW session in a user-only temp file instead.
  keyctl-shim = pkgs.writeShellScriptBin "keyctl" ''
    CACHE_FILE="''${TMPDIR:-/tmp}/bw_session_cache_$(id -u)"
    case "$1" in
      request)
        if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
          echo "1"
          exit 0
        fi
        exit 1
        ;;
      add)
        echo "$4" > "$CACHE_FILE"
        chmod 600 "$CACHE_FILE"
        echo "1"
        ;;
      pipe)
        cat "$CACHE_FILE"
        ;;
      timeout|purge)
        [ "$1" = "purge" ] && rm -f "$CACHE_FILE"
        exit 0
        ;;
    esac
  '';

  qute-bitwarden-wrapped = pkgs.writeShellScriptBin "qute-bitwarden" ''
    export PATH="${lib.makeBinPath ([
      pythonWithDeps
      pkgs.bitwarden-cli
    ] ++ (if isDarwin then [ keyctl-shim ] else [ pkgs.keyutils ]))}:$PATH"
    exec ${pythonWithDeps}/bin/python3 ${qute-bitwarden-src} "$@"
  '';
in
{
  programs.qutebrowser = {
    enable = true;
    keyBindings = {
      normal = {
        ",p" = "spawn --userscript ${qute-bitwarden-wrapped}/bin/qute-bitwarden -d ${dmenu-wrapper}/bin/qb-dmenu -p ${password-prompt-wrapper}/bin/qb-password-prompt";
        ",u" = "spawn --userscript ${qute-bitwarden-wrapped}/bin/qute-bitwarden -d ${dmenu-wrapper}/bin/qb-dmenu -p ${password-prompt-wrapper}/bin/qb-password-prompt --username-only";
        ",P" = "spawn --userscript ${qute-bitwarden-wrapped}/bin/qute-bitwarden -d ${dmenu-wrapper}/bin/qb-dmenu -p ${password-prompt-wrapper}/bin/qb-password-prompt --password-only";
        ",t" = "spawn --userscript ${qute-bitwarden-wrapped}/bin/qute-bitwarden -d ${dmenu-wrapper}/bin/qb-dmenu -p ${password-prompt-wrapper}/bin/qb-password-prompt --totp";
      };
    };
  };

  home.packages = [
    pkgs.bitwarden-cli
  ] ++ lib.optionals isDarwin [
    pkgs.choose-gui
  ] ++ lib.optionals (!isDarwin) [
    pkgs.rofi
  ];
}
