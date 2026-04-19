{ username, ... }:

{
  imports = [
    ../../modules/home/editors/neovim.nix
    ../../modules/home/editors/zed.nix
    ../../modules/home/git.nix
    ../../modules/home/packages/node.nix
    ../../modules/home/shell/fish.nix
    ../../modules/home/shell/starship.nix
    ../../modules/home/terminal/ghostty.nix
    ../../modules/home/terminal/tmux.nix
    ../../modules/home/dev.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
  };

  programs.home-manager.enable = true;
}
