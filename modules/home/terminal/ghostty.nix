{ config, pkgs, lib, ... }:

{
  home.file.".config/ghostty/config".source = ../../../config/ghostty/config;
}
