# dots

Personal macOS dotfiles managed with nix-darwin, home-manager, and Homebrew.

The flake currently targets Apple Silicon and exposes one host configuration:
`kybook`.

## Install

Run the bootstrap script as your normal user:

```sh
curl -fsSL https://raw.githubusercontent.com/k1tyoodev/dots/main/scripts/setup.sh | bash
```

The script installs Nix when needed, checks the matching host under `hosts/`,
runs `darwin-rebuild`, installs user-scoped toolchains, and only prompts for
`sudo` during the system switch.

## Rebuild

After the first setup, rebuild from this checkout with the Fish helper:

```sh
rebuild
```

Equivalent command:

```sh
sudo darwin-rebuild switch --flake ~/.dots
```

## Structure

Directory tree is intentionally capped at two nested levels.

```text
.
|-- .github/                  # repository automation
|   `-- workflows/            # scheduled flake input updates
|-- config/                   # app configs linked into $HOME
|   |-- bat/                  # bat Cursor Dark/Light themes
|   |-- btop/                 # btop Cursor Dark/Light themes
|   |-- ghostty/              # Ghostty terminal config
|   |-- nvim/                 # Neovim Lua config and plugin lockfile
|   |-- theme/                # shared macOS appearance helpers
|   `-- vite-plus/            # Vite+ defaults
|-- hosts/                    # machine entrypoints
|   `-- kybook/               # nix-darwin and home-manager config
|-- modules/                  # reusable Nix modules
|   |-- darwin/               # macOS system and Homebrew modules
|   `-- home/                 # user shell, editor, terminal, git, and dev modules
|-- scripts/                  # bootstrap scripts
|   `-- setup.sh              # first-run macOS setup
|-- .gitignore                # repository ignore rules
|-- flake.lock                # locked Nix input revisions
|-- flake.nix                 # main Nix flake entrypoint
`-- README.md                 # project overview
```

## Managed Tools

- system: nix-darwin, home-manager, nix-homebrew
- shell: Fish, Starship, fzf, zoxide, eza, direnv
- terminal: Ghostty, tmux
- editor: Neovim
- dev: Git, GitHub CLI, ripgrep, fd, bat, btop, yazi
- runtimes: Vite+, Bun, pnpm, Rust, uv
- theme: Cursor Dark / Cursor Light, following macOS appearance
