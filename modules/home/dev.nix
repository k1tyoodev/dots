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

  # yazi file manager
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  # btop theme
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "vesper";
      theme_background = true;
    };
  };
  home.file.".config/btop/themes/vesper.theme".source = ../../config/btop/themes/vesper.theme;

  # bat theme
  programs.bat = {
    enable = true;
    config = {
      theme = "vesper";
      style = "numbers,changes";
      tabs = "2";
    };
    themes.vesper = {
      src = ../../config/bat/themes;
      file = "vesper.tmTheme";
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
