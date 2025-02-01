{ config, pkgs, ... }:
{
  # The home.stateVersion option does not have a default and must be set
  # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];
  home.packages = [
    # Python
    pkgs.python313

    # C/C++
    pkgs.gnumake42
    pkgs.clang_19
    pkgs.lldb_19

    # Rust
    pkgs.cargo

    # Frontend
    pkgs.yarn
    pkgs.nodejs
  ];
}
