{ config, pkgs, lib, ... }:

{
  home.file.".config/ghostty/config".source = ../../../config/ghostty/config;
  home.file.".config/ghostty/ghostty.icns".source = ../../../config/ghostty/ghostty.icns;
  home.file.".config/ghostty/themes" = {
    source = ../../../config/ghostty/themes;
    recursive = true;
  };
}
