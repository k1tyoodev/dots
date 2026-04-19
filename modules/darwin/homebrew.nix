{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      # "zap" removes everything not listed here
      # start with "none" until verified, then switch to "zap"
      cleanup = "none"; # change to "zap" after verifying all packages are listed
      autoUpdate = true;
      upgrade = true;
    };

    caskArgs.no_quarantine = true;

    taps = [];

    brews = [
      # core
      "bash"
      "fish"
      "starship"
      "tmux"
      "neovim"
      "btop"
      "mole"

      # search & navigation
      "fd"
      "fzf"
      "ripgrep"
      "zoxide"
      "eza"
      "bat"
      "television" # modern fzf
      "yazi"       # tui finder

      # dev tools
      "ast-grep"
      "scc"
      "typos-cli"
      "glow"
      "awscli"
      "tldr"

      # languages & runtimes
      "pipx"      # Avoid polluting the global Python environment
      "uv"
      "ruff"      # linter + formatter
      "ty"        # type checker
      "zig"

      # media
      "ffmpeg"
      "imagemagick"
      "poppler"
      "resvg"

      # data
      "jq"
      "sqlite"
      "redis"
      "postgresql@18"

      # network
      "curl"
      "wget"
      "cloudflared"
      "openssh"

      # compression
      "sevenzip"
      "zstd"
      "xz"

      # build deps (often pulled in by others, but explicit is good)
      "openssl@3"
      "readline"
      "ncurses"
      "gettext"
      "ca-certificates"
    ];

    casks = [
      # software
      "alcove"
      "cleanshot"
      "iina"
      "maczip"
      "notion"
      "raycast"

      # dev
      "zed"
      "ghostty"
      "cursor"
      "git-credential-manager"
      "google-chrome"
      "hoppscotch"
      "linear-linear"
      "ngrok"
      "orbstack"
    ];
  };
}
