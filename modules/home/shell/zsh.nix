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
        "$HOME/.local/share/mise/shims"
        "$HOME/.nix-profile/bin"
        "/etc/profiles/per-user/$USER/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "$HOME/.cargo/bin"
        $path
      )

      eval "$(/opt/homebrew/bin/mise activate zsh)"

      # Match terminal tools to the macOS appearance.
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

      # Clear the previous autosuggestion color when reloading an existing shell.
      unset ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE

      # Local secrets (zsh format).
      if [[ -f "$HOME/.dots/secrets/github.zsh" ]]; then
        source "$HOME/.dots/secrets/github.zsh"
      fi

      # proxy
      if /usr/bin/nc -z 127.0.0.1 6152 2>/dev/null; then
        export https_proxy=http://127.0.0.1:6152
        export http_proxy=http://127.0.0.1:6152
      fi

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
      t = "tldr";

      ll = "eza -l -g --git --group-directories-first";
      la = "eza -la -g --git --group-directories-first";
      llt = "eza -1 --git --tree --git-ignore";

      zshrc = "nvim ~/.dots/modules/home/shell/zsh.nix";
      reload = "source ~/.zshrc";

      py = "python3";
      pn = "pnpm";
      ds = "caffeinate -d";

      # ai coding
      cc = "claude";
      c = "codex --yolo";
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
    package = null; # installed via homebrew
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
