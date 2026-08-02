{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.ollama;
in
{
  options.pixos.bundles.ollama.enable = lib.mkEnableOption "Ollama bundle";

  config = lib.mkIf cfg.enable {
    # Local LLM server. Defaults to CPU inference — safe on any host. The
    # Framework's AMD iGPU can do ROCm, but that pulls a large rocm closure
    # and usually needs a per-GPU HSA_OVERRIDE_GFX_VERSION, so it's left off
    # here; set `acceleration = "rocm";` (and the override) to opt in.
    services.ollama = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      ollama
      claude-code
      codex
    ];
  };
}
