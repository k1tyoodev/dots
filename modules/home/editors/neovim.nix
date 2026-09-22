{ config, pkgs, lib, ... }:

{
  # nvim-treesitter's parser installer uses the CLI to build grammars.
  home.packages = [ pkgs.tree-sitter ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # symlink nvim config (complex lua config, not worth converting to nix)
  home.file.".config/nvim" = {
    source = ../../../config/nvim;
    recursive = true;
  };
}
