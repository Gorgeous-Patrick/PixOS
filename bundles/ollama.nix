{
  config,
  options,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.ollama;
in
{
  options.pixos.bundles.ollama.enable = lib.mkEnableOption "Ollama bundle";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = with pkgs; [
          ollama
          claude-code
          codex
        ];
      }
      # The ollama systemd service is a NixOS-only module; nix-darwin has no
      # `services.ollama` (referencing that option path at all — even under a
      # false mkIf — errors on Darwin). Guard on whether the option exists rather
      # than on pkgs.stdenv (the latter conditions config *structure* on pkgs and
      # causes infinite recursion). On Darwin we ship just the package (run
      # `ollama serve` yourself). CPU inference by default — safe on any host; the
      # Framework's AMD iGPU can do ROCm, but that pulls a large rocm closure and
      # usually needs a per-GPU HSA_OVERRIDE_GFX_VERSION, so set
      # `acceleration = "rocm";` (and the override) to opt in.
      (lib.optionalAttrs (options ? services.ollama) {
        services.ollama.enable = true;
      })
    ]
  );
}
