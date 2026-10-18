# dots

Personal macOS dotfiles managed with nix-darwin, home-manager, and Homebrew.

The flake currently targets Apple Silicon and exposes one host configuration:
`kybook`.

## Install

This flake targets an Apple Silicon Mac with the account short name `k1tyoo`
and LocalHostName `kybook`. Set those names first, or update `flake.nix`,
`hosts/kybook/`, and `scripts/setup.sh` for the new Mac. Git must work before
setup can clone the repo; install the Xcode Command Line Tools if
`git --version` fails.

Run the bootstrap script as your normal user:

```sh
curl -fsSL https://raw.githubusercontent.com/k1tyoodev/dots/main/scripts/setup.sh | bash
```

The script installs Nix when needed, checks the matching host under `hosts/`,
runs `darwin-rebuild`, installs user-scoped toolchains, and only prompts for
`sudo` during the system switch.

Homebrew installs ComicShannsMono Nerd Font for Ghostty and Paper Mono.
Git commits are signed by default; import the private GPG key matching
`6C3567C3144352E3` before committing.
In repos that use Git LFS, run `git lfs install --local` to add its push hook.
The setup script installs Codex CLI for the `c` alias. The `cc` and `a`
aliases need their CLIs installed separately.

If Home Manager creates `.backup` files, review them before removing them.

## Rebuild

After the first setup, rebuild from this checkout with the helper:

```sh
rebuild
```

Equivalent command:

```sh
sudo darwin-rebuild switch --flake ~/.dots
```

Rebuilds do not automatically update or upgrade Homebrew packages; update them separately when intended.

After changing the language versions in `modules/home/dev.nix`,
rebuild and run `(cd ~ && /opt/homebrew/bin/mise install)`, then open a new terminal.
mise manages Node.js 24, the latest stable Python and Go, and Rust's stable
channel through rustup. Project version files override these global defaults.
Keep global version changes in Nix; the generated mise config is read-only.
uv remains available for Python dependencies and virtual environments.
The setup script installs pnpm, Codex CLI, and portless globally through npm.
To install them on an existing machine, run
`npm install -g pnpm @openai/codex portless` and `mise reshim`.
If npm uses a per-Node-version prefix, repeat this after switching Node versions.

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
|   `-- theme/                # shell color helpers
|-- hosts/                    # machine entrypoints
|   `-- kybook/               # nix-darwin and home-manager config
|-- modules/                  # reusable Nix modules
|   |-- darwin/               # macOS system and Homebrew modules
|   `-- home/                 # user shell, editor, terminal, git, and dev modules
|-- scripts/                  # bootstrap scripts
|   `-- setup.sh              # first-run macOS setup
|-- secrets/                  # local-only shell exports, never committed
|   `-- github.zsh            # GITHUB_PAT_TOKEN, created by hand
|-- .gitignore                # repository ignore rules
|-- flake.lock                # locked Nix input revisions
|-- flake.nix                 # main Nix flake entrypoint
`-- README.md                 # project overview
```

## Managed Tools

- system: nix-darwin, home-manager, nix-homebrew
- shell: zsh, Starship, fzf, zoxide, eza, direnv
- terminal: Ghostty, tmux
- editor: Neovim
- dev: Git, GitHub CLI, ripgrep, fd, bat, btop, nil
- runtimes: Node.js 24 with bundled npm, Python, Rust, and Go (mise); uv
- npm global tools: pnpm, Codex CLI, portless
- theme: Ghostty, bat, tmux, and Neovim follow macOS appearance; shell fzf and btop use matching Cursor Light/Dark palettes
