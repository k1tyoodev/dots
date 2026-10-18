{ config, pkgs, ... }:

{
  home.sessionPath = [ "$HOME/.local/share/mise/shims" "$HOME/.local/bin" ];

  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.local";

  xdg.configFile."mise/config.toml".text = ''
    [tools]
    node = "24"
    python = "latest"
    rust = "stable"
    go = "latest"

    [settings]
    idiomatic_version_file_enable_tools = ["node", "python", "rust", "go"]
  '';

  # fd (better find) - installed via homebrew but configure here
  programs.fd = {
    enable = true;
    package = null;
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

  programs.btop = {
    enable = true;
    package = null; # installed via homebrew
    settings = {
      color_theme = "cursor-light";
      theme_background = true;
    };
  };
  home.file.".config/btop/themes/cursor-dark.theme".source = ../../config/btop/themes/cursor-dark.theme;
  home.file.".config/btop/themes/cursor-light.theme".source = ../../config/btop/themes/cursor-light.theme;
  home.file.".config/btop/cursor-dark.conf".source = ../../config/btop/cursor-dark.conf;
  home.file.".config/btop/cursor-light.conf".source = ../../config/btop/cursor-light.conf;

  programs.bat = {
    enable = true;
    config = {
      theme = "auto:system";
      "theme-light" = "Cursor Light";
      "theme-dark" = "Cursor Dark";
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
