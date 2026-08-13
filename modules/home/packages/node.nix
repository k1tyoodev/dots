{ config, pkgs, lib, ... }:

let
  nodeVersion = "24.14.0";
in
{
  home.sessionVariables = {
    VITE_PLUS_NODE_VERSION = nodeVersion;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.vite-plus/js_runtime/node/${nodeVersion}/bin"
  ];

  home.file.".vite-plus/config.json".source = ../../../config/vite-plus/config.json;
}
