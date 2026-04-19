{ config, pkgs, lib, ... }:

{
  home.sessionVariables = {
    VITE_PLUS_NODE_VERSION = "24.14.0";
  };

  home.file.".vite-plus/config.json".source = ../../../config/vite-plus/config.json;
}
