{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    signing = {
      key = "6C3567C3144352E3";
      signByDefault = true;
    };

    ignores = [
      ".DS_Store"
      "._*"
      ".idea/"
      ".vscode/"
      "*.swp"
      "*.swo"
      "*~"
      "**/.claude/settings.local.json"
      ".env"
      ".env.local"
      ".env*.local"
      "node_modules/"
      "__pycache__/"
      "*.pyc"
      ".venv/"
      "venv/"
    ];

    settings = {
      user = {
        name = "k1tyoodev";
        email = "softdev.au@outlook.com";
      };

      alias = {
        d = "diff";
        co = "checkout";
        cm = "commit";
        st = "status";
        a = "add";
        hist = "log --pretty=format:\"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)\" --graph --date=relative --decorate --all";
        llog = "log --graph --name-status --pretty=format:\"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset\" --date=relative";
        ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
        pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
        open = "!gh browse";
        nuke = "!git restore . && git clean -fd";
      };

      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        whitespace = "error";
        preloadindex = true;
      };

      merge.conflictStyle = "zdiff3";

      status = {
        branch = true;
        showStash = true;
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      pull = {
        default = "current";
        rebase = true;
      };

      rebase.autoStash = true;

      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = false;
    };
  };
}
