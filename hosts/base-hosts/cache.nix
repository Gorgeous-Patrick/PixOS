{ lib, pkgs, ... }:

{
  # Shared by NixOS, nix-darwin, and the reusable server module.
  # NixOS merges in cache.nixos.org; Darwin needs it explicitly when overriding.
  nix.settings = {
    substituters = [
      "https://cache.patrickli.one/pixos"
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [ "https://cache.nixos.org/" ];
    trusted-public-keys = [
      "pixos:x35yefaqZmg4ly18RPZl/8kWp7IzIVo6N+O24svVYig="
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
