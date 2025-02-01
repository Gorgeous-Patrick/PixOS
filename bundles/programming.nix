{ config, pkgs, ... }:
{
  # The home.stateVersion option does not have a default and must be set
  # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];
  home.packages = [
    # Python
    pkgs.python313

    # C/C++
    pkgs.gcc14
    pkgs.gdb
    pkgs.gnumake42

    # Rust
    pkgs.cargo

    # Frontend
    pkgs.yarn
    pkgs.nodejs
  ];
}
