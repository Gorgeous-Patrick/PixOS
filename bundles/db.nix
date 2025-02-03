# DB essential packages
{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.mysql84
    pkgs.libmysqlclient
    pkgs.pkg-config
  ];
}
