# Basic packages for coding
{ config, pkgs, ... }:
{
  home.packages = [
    # Python
    pkgs.python313
    pkgs.black

    # C/C++
    pkgs.gnumake42
    pkgs.clang_19
    pkgs.clang-tools_19
    pkgs.lldb_19

    # Rust
    pkgs.rustup

    # Frontend
    pkgs.yarn
    pkgs.nodejs
  ];
}
