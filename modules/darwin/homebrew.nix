{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    onActivation.cleanup = "none";

    taps = [];

    brews = [
      # core
      "bash"
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

      # dev tools
      "ast-grep"
      "gh"
      "git-lfs"
      "gnupg"
      "scc"
      "typos-cli"
      "glow"
      "awscli"
      "tlrc"

      # languages & runtimes
      "mise"
      "pipx"
      "uv"
      "ruff"      # linter + formatter
      "ty"

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
      "nginx"
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
      "localsend"
      "maczip"
      "mos@beta"
      "notion"
      "raycast"
      "chatgpt"
      "grok-bot"
      "linear"
      "zotero"

      # dev
      "ghostty"
      "cursor"
      "git-credential-manager"
      "google-chrome"
      "helium-browser"
      "hoppscotch"
      "paper-design"

      # fonts
      "font-paper-mono"
      "font-comic-shanns-mono-nerd-font"
    ];
  };
}
