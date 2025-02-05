nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./simple.nix

