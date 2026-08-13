{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bindkey -v

      # homebrew
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"

      # Keep PATH entries unique while preserving their declared priority.
      typeset -U path PATH
      path=(
        "$HOME/.local/bin"
        "$HOME/.kimi-code/bin"
        "$HOME/.nix-profile/bin"
        "/etc/profiles/per-user/$USER/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "$HOME/.bun/bin"
        "$HOME/Library/pnpm"
        "$HOME/.cargo/bin"
        "$HOME/.opencode/bin"
        $path
      )

      # vite+ (its generated 0.2.1 script requests the invalid shell name
      # "shell_zsh"; load the environment/function section and initialize the
      # completion protocol with the supported "zsh" name instead).
      if [[ -f "$HOME/.vite-plus/env" ]]; then
        source <(sed '/^# Dynamic shell completion/,$d' "$HOME/.vite-plus/env")
        if (( $+commands[vp] )); then
          eval "$(VP_COMPLETE=zsh vp completions)"
        fi
      fi

      # bun / pnpm
      export BUN_INSTALL="$HOME/.bun"
      export PNPM_HOME="$HOME/Library/pnpm"

      # cargo / rustup
      [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

      # Keep fzf, zoxide, and btop aligned with macOS appearance.
      __cursor_theme_sync() {
        local appearance colors
        appearance="$("$HOME/.config/theme/current-appearance")"
        colors="$("$HOME/.config/theme/fzf-colors")"

        export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border $colors"
        export _ZO_FZF_OPTS="--no-sort $colors"

        if [[ "$appearance" == light ]]; then
          export BTOP_CONFIG="$HOME/.config/btop/cursor-light.conf"
        else
          export BTOP_CONFIG="$HOME/.config/btop/cursor-dark.conf"
        fi
      }

      autoload -Uz add-zsh-hook
      add-zsh-hook precmd __cursor_theme_sync
      __cursor_theme_sync

      # Local secrets (zsh format).
      if [[ -f "$HOME/.dots/secrets/github.zsh" ]]; then
        source "$HOME/.dots/secrets/github.zsh"
      fi

      # proxy
      export https_proxy=http://127.0.0.1:6152
      export http_proxy=http://127.0.0.1:6152

      # OrbStack integration
      source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || true

      o() {
        open "$@" -a Cursor
      }

      btop() {
        __cursor_theme_sync
        command btop --config "$BTOP_CONFIG" "$@"
      }

      rebuild() {
        local darwin_rebuild
        darwin_rebuild="$(command -v darwin-rebuild)"
        if [[ -z "$darwin_rebuild" ]]; then
          echo "rebuild: darwin-rebuild not found" >&2
          return 127
        fi

        sudo "$darwin_rebuild" switch --flake ~/.dots
      }
    '';

    shellAliases = {
      g = "git";
      t = "tlrd";

      ll = "eza -l -g --git --group-directories-last";
      la = "eza -la -g --git --group-directories-last";
      llt = "eza -1 --git --tree --git-ignore";

      zshrc = "nvim ~/.dots/modules/home/shell/zsh.nix";
      reload = "source ~/.zshrc";

      py = "python3";
      pn = "pnpm";
      ds = "caffeinate -d";

      # ai coding
      oc = "opencode";
      uc = "npx ccusage@latest codex --offline";
      c = "codex --yolo";
      cc = "claude";
      a = "agent -f";
      scc = "scc --no-complexity --no-cocomo --no-size";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
