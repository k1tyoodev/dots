{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    onActivation.cleanup = "none";

    taps = [];

    brews = [
      # core
      "bash"
      "tmux"
      "btop"
      "mole"

      # search & navigation
      "fd"
      "ripgrep"
      "eza"
      "television" # modern fzf

      # dev tools
      "scc"
      "tlrc"

      # languages & runtimes
      "node@24"   # Node.js with bundled npm
      "uv"
      "ruff"      # linter + formatter

      # media
      "ffmpeg"
      "imagemagick"
      "poppler"

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
      "zotero"

      # dev
      "ghostty"
      "cursor"
      "git-credential-manager"
      "google-chrome"
      "hoppscotch"
      "orbstack"
      "figma"
    ];
  };
}
