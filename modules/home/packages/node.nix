{ config, pkgs, lib, ... }:

let
  # Vite+ manages its own Node tree under ~/.vite-plus/js_runtime/node.
  # This pin is independent of the mise-managed global Node; the two coexist
  # and PATH order decides which one a bare `node` resolves to.
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
