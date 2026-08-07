{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.davinci-resolve;

  davinciResolve = pkgs.symlinkJoin {
    name = "davinci-resolve-x11";
    paths = [ pkgs.davinci-resolve ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/davinci-resolve \
        --set-default QT_QPA_PLATFORM xcb \
        --set-default RUSTICL_ENABLE radeonsi
    '';

    inherit (pkgs.davinci-resolve) meta;
  };
in
{
  options.pixos.bundles.davinci-resolve.enable = lib.mkEnableOption "DaVinci Resolve bundle";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        mesa.opencl
      ];
    };

    environment.systemPackages = [
      davinciResolve
    ];
  };
}
