{ ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_vi_key_bindings
      set fish_greeting ""

      # terminal
      set -gx TERM xterm-256color

      # homebrew
      eval (/opt/homebrew/bin/brew shellenv)

      # nix
      fish_add_path $HOME/.nix-profile/bin
      fish_add_path /etc/profiles/per-user/$USER/bin
      fish_add_path /run/current-system/sw/bin
      fish_add_path /nix/var/nix/profiles/default/bin

      # vite+
      if test -f "$HOME/.vite-plus/env.fish"
        source "$HOME/.vite-plus/env.fish"
      end

      # bun
      set -gx BUN_INSTALL "$HOME/.bun"
      fish_add_path $BUN_INSTALL/bin

      # pnpm
      set -gx PNPM_HOME "$HOME/Library/pnpm"
      if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
      end

      # cargo
      fish_add_path $HOME/.cargo/bin

      # opencode
      fish_add_path $HOME/.opencode/bin

      # local secrets
      if test -f "$HOME/.dots/secrets/github.fish"
        source "$HOME/.dots/secrets/github.fish"
      end

      # proxy
      set -gx https_proxy http://127.0.0.1:8234
      set -gx http_proxy http://127.0.0.1:8234
      set -gx all_proxy socks5://127.0.0.1:8235

      # orbstack integration
      source ~/.orbstack/shell/init2.fish 2>/dev/null || true
    '';

    shellAliases = {
      g = "git";
      t = "tldr";
      o = "open $argv -a 'Cursor'";

      ll = "eza -l -g --git --group-directories-last";
      la = "eza -la -g --git --group-directories-last";
      llt = "eza -1 --git --tree --git-ignore";

      fishrc = "nvim ~/.config/fish/config.fish";
      reload = "source ~/.config/fish/config.fish";

      py = "python3";
      pn = "pnpm";
      ds = "caffeinate -d";

      # ai coding
      uc = "npx @ccusage/codex@latest";
      oc = "OPENCODE_DISABLE_CLAUDE_CODE=1 opencode";
      c = "codex --yolo";
      cc = "claude";
      a = "agent -f";
      scc = "scc --no-complexity --no-cocomo --no-size";

    };

    functions = {
      rebuild = ''
        set -l darwin_rebuild (command -v darwin-rebuild)
        if test -z "$darwin_rebuild"
          echo "rebuild: darwin-rebuild not found" >&2
          return 127
        end

        sudo $darwin_rebuild switch --flake ~/.dots
      '';
    };
  };

  # zoxide (better cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # fzf
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--color=bg:#101010,bg+:#232323,fg:#A0A0A0,fg+:#FFFFFF,hl:#FFC799,hl+:#FFC799,pointer:#FFC799,prompt:#FFC799,info:#5C5C5C"
    ];
  };

  # eza (better ls)
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };

  # direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
