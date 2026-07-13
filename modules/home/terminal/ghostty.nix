{ config, pkgs, lib, ... }:

{
  home.file.".config/ghostty/config".source = ../../../config/ghostty/config;
  home.file.".config/ghostty/themes" = {
    source = ../../../config/ghostty/themes;
    recursive = true;
  };
}
