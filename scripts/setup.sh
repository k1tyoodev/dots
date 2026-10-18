#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# check if running on macOS
[[ "$OSTYPE" == "darwin"* ]] || error "This setup only supports macOS"

# this script installs user-scoped tools and only escalates where needed
[[ "${EUID:-$(id -u)}" -ne 0 ]] || error "Run this script without sudo: bash ./scripts/setup.sh"

# check architecture
ARCH="$(uname -m)"
[[ "$ARCH" == "arm64" ]] || warn "This config is tuned for Apple Silicon; detected $ARCH"

log "Starting setup..."

# verify this personal flake can target the current Mac before installing Nix
[[ "$(id -un)" == "k1tyoo" ]] || error "This flake targets macOS user k1tyoo; update flake.nix for this account first"
HOSTNAME="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
[[ "$HOSTNAME" == "kybook" ]] || error "This flake targets LocalHostName kybook; set it or add this Mac to flake.nix first"
git --version >/dev/null 2>&1 || error "Git is required before setup can clone dots; install the Xcode Command Line Tools first"

# 1. install nix (if not installed)
if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix via Determinate Systems installer"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  success "Nix is already installed"
fi

# 2. clone dotfiles (if not already there)
DOTS_DIR="${DOTS_DIR:-$HOME/.dots}"
DOTS_REPO_URL="${DOTS_REPO_URL:-https://github.com/k1tyoodev/dots.git}"

if [[ ! -d "$DOTS_DIR" ]]; then
  log "Cloning dots into $DOTS_DIR"
  git clone "$DOTS_REPO_URL" "$DOTS_DIR"
else
  success "Using existing dots at $DOTS_DIR"
fi

cd "$DOTS_DIR"
mkdir -p "$DOTS_DIR/secrets"

# 3. confirm host config exists
log "Detected hostname: $HOSTNAME"

# check if host config exists
[[ -d "hosts/$HOSTNAME" ]] || error "No host config found at hosts/$HOSTNAME"

# 4. first-time nix-darwin setup
if ! command -v darwin-rebuild >/dev/null 2>&1; then
  log "Running first nix-darwin switch (requires sudo)"
  sudo "$(command -v nix)" run nix-darwin -- switch --flake ".#$HOSTNAME"
else
  DARWIN_REBUILD_BIN="$(command -v darwin-rebuild)"
  log "Running darwin-rebuild (requires sudo)"
  sudo "$DARWIN_REBUILD_BIN" switch --flake ".#$HOSTNAME"
fi

success "System configured"

# 5. install language toolchains
log "Installing Node.js, Python, Rust, and Go via mise"
(cd "$HOME" && /opt/homebrew/bin/mise install)

log "Installing pnpm, Codex CLI, and portless via npm"
(cd "$HOME" && /opt/homebrew/bin/mise exec -- npm install -g pnpm @openai/codex portless)
/opt/homebrew/bin/mise reshim

# 6. post-install reminders
echo
log "Post-install reminders:"
echo "  1. Authenticate with GitHub:    gh auth login"
echo "  2. Create local secrets:        echo 'export GITHUB_PAT_TOKEN=...' > ~/.dots/secrets/github.zsh"
echo "  3. Optional: install and configure Graphite separately"
echo "  4. Install macOS apps:          magnet, bob, infuse"
echo "  5. Restart your terminal"
echo ""
success "Setup complete!"
