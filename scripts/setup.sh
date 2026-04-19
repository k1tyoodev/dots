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
DOTS_REPO_URL="${DOTS_REPO_URL:-}"

if [[ ! -d "$DOTS_DIR" ]]; then
  [[ -n "$DOTS_REPO_URL" ]] || error "Set DOTS_REPO_URL before first setup clone"
  log "Cloning dots into $DOTS_DIR"
  git clone "$DOTS_REPO_URL" "$DOTS_DIR"
else
  success "Using existing dots at $DOTS_DIR"
fi

cd "$DOTS_DIR"

# 3. get hostname
HOSTNAME="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
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

# 4b. clean up home-manager *.backup files (generated when local config diverges from Nix store)
if command -v fd >/dev/null 2>&1; then
  log "Cleaning up home-manager backup files in ~/.config"
  fd --hidden --no-ignore --type f --extension backup . "$HOME/.config" --exec rm
else
  warn "fd not on PATH — skipping backup cleanup (run manually: fd -HI -tf -e backup . ~/.config -x rm)"
fi

# 5. install vite+
if ! command -v vite >/dev/null 2>&1 && ! [[ -x "$HOME/.vite-plus/bin/vite" ]]; then
  log "Installing Vite+ toolchain"
  curl -fsSL https://vite.plus/install.sh | sh
else
  success "vite+ already installed"
fi

# 6. install bun
if ! command -v bun >/dev/null 2>&1 && ! [[ -x "$HOME/.bun/bin/bun" ]]; then
  log "Installing Bun"
  curl -fsSL https://bun.sh/install | bash
else
  success "bun already installed"
fi

# 7. install pnpm
if ! command -v pnpm >/dev/null 2>&1 && ! [[ -x "$HOME/Library/pnpm/pnpm" ]]; then
  log "Installing pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
else
  success "pnpm already installed"
fi

# 8. install opencode
if ! command -v opencode >/dev/null 2>&1 && ! [[ -x "$HOME/.opencode/bin/opencode" ]]; then
  log "Installing opencode"
  curl -fsSL https://opencode.ai/install | bash
else
  success "opencode already installed"
fi

# 9. post-install reminders
echo
log "Post-install reminders:"
echo "  1. Authenticate with GitHub:    gh auth login"
echo "  2. Configure Graphite:          graphite auth --token ..."
echo "  3. Install opencode deps:       cd ~/.config/opencode && bun install"
echo "  4. Install macOS apps:          magnet, bob, localsend, infuse"
echo "  4. Restart your terminal"
echo ""
success "Setup complete!"
