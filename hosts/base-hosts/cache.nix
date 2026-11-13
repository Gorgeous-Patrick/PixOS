{ ... }:

{
  # NixOS and nix-darwin already include cache.nixos.org; add PixOS first.
  nix.settings = {
    substituters = [ "https://cache.patrickli.one/pixos" ];
    trusted-public-keys = [ "pixos:x35yefaqZmg4ly18RPZl/8kWp7IzIVo6N+O24svVYig=" ];
  };
}
