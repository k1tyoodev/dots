#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# check if running on macOS
[[ "$OSTYPE" == "darwin"* ]] || error "This setup only supports macOS"

# this script installs user-scoped tools and only escalates where needed
[[ "${EUID:-$(id -u)}" -ne 0 ]] || error "Run this script without sudo: bash ./scripts/setup.sh"

# check architecture
ARCH="$(uname -m)"
[[ "$ARCH" == "arm64" ]] || error "This flake requires native Apple Silicon (arm64); detected $ARCH. On Apple Silicon, reopen Terminal without Rosetta."

log "Starting setup..."

# verify this personal flake can target the current Mac before installing Nix
[[ "$(id -un)" == "k1tyoo" ]] || error "This flake targets macOS user k1tyoo; update flake.nix for this account first"
HOSTNAME="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
[[ "$HOSTNAME" == "kybook" ]] || error "This flake targets LocalHostName kybook; set it or add this Mac to flake.nix first"
git --version >/dev/null 2>&1 || error "Git is required before setup can clone dots; install the Xcode Command Line Tools first"

# 1. validate or clone the checkout before installing system tools
DOTS_DIR="${DOTS_DIR:-$HOME/.dots}"
DOTS_REPO_URL="${DOTS_REPO_URL:-https://github.com/k1tyoodev/dots.git}"
[[ "$DOTS_DIR" == "$HOME/.dots" ]] || error "This config requires the checkout at $HOME/.dots"

if [[ -f "${BASH_SOURCE[0]:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  [[ -d "$DOTS_DIR/scripts" && "$SCRIPT_DIR" == "$(cd "$DOTS_DIR/scripts" && pwd -P)" ]] || error "Run the setup script from $HOME/.dots/scripts/setup.sh"
fi

if [[ ! -e "$DOTS_DIR" && ! -L "$DOTS_DIR" ]]; then
  log "Cloning dots into $DOTS_DIR"
  git clone "$DOTS_REPO_URL" "$DOTS_DIR"
fi

[[ -d "$DOTS_DIR" ]] || error "$DOTS_DIR is not a directory"
DOTS_ROOT="$(cd "$DOTS_DIR" && pwd -P)"
REPO_ROOT="$(git -C "$DOTS_DIR" rev-parse --show-toplevel 2>/dev/null)" || error "$DOTS_DIR is not a Git checkout"
[[ "$REPO_ROOT" == "$DOTS_ROOT" ]] || error "$DOTS_DIR must be the Git repository root"
for required in flake.nix flake.lock "hosts/$HOSTNAME/default.nix" "hosts/$HOSTNAME/home.nix" scripts/setup.sh; do
  [[ -f "$DOTS_DIR/$required" ]] || error "Missing $required in $DOTS_DIR"
done

cd "$DOTS_DIR"
success "Using validated checkout at $DOTS_DIR"

# 2. install nix (if not installed)
if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix via Determinate Systems installer"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  success "Nix is already installed"
fi

# 3. create user directories
mkdir -p "$DOTS_DIR/secrets" "$HOME/Pictures/Screenshots"

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

export NPM_CONFIG_PREFIX="$HOME/.local"
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
