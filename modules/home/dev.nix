{ config, pkgs, ... }:

{
  # fd (better find) - installed via homebrew but configure here
  programs.fd = {
    enable = true;
    ignores = [
      ".git/"
      "node_modules/"
      ".direnv/"
      "target/"
      "__pycache__/"
    ];
  };

  # ripgrep config
  home.file.".ripgreprc".text = ''
    --smart-case
    --hidden
    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!.direnv/*
    --glob=!target/*
  '';

  home.sessionVariables = {
    RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc";
  };

  # Cursor Dark, including launches outside the shell wrapper.
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "cursor-dark";
      theme_background = true;
    };
  };
  home.file.".config/btop/themes/cursor-dark.theme".source = ../../config/btop/themes/cursor-dark.theme;
  home.file.".config/btop/themes/cursor-light.theme".source = ../../config/btop/themes/cursor-light.theme;
  home.file.".config/btop/cursor-dark.conf".source = ../../config/btop/cursor-dark.conf;
  home.file.".config/btop/cursor-light.conf".source = ../../config/btop/cursor-light.conf;

  # Keep bat on Cursor Dark.
  programs.bat = {
    enable = true;
    config = {
      theme = "Cursor Dark";
      style = "numbers,changes";
      tabs = "2";
    };
    themes."Cursor Dark" = {
      src = ../../config/bat/themes;
      file = "cursor-dark.tmTheme";
    };
    themes."Cursor Light" = {
      src = ../../config/bat/themes;
      file = "cursor-light.tmTheme";
    };
  };

  # gh
  programs.gh = {
    enable = true;
    settings = {
      version = "1";
      git_protocol = "https";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "";
      aliases.co = "pr checkout";
      color_labels = "disabled";
      accessible_colors = "disabled";
      accessible_prompter = "disabled";
      spinner = "enabled";
    };
  };
}
