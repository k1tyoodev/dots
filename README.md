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

Install the Command Line Tools with `xcode-select --install`, wait for the
installer to finish, and verify `git --version`. If needed, set the hostname
with `sudo scutil --set LocalHostName kybook`.

Clone to the required location and run the bootstrap script as your normal user:

```sh
git clone https://github.com/k1tyoodev/dots.git ~/.dots
cd ~/.dots
bash scripts/setup.sh
```

Alternatively, let the script clone to `~/.dots`:

```sh
curl -fsSL https://raw.githubusercontent.com/k1tyoodev/dots/main/scripts/setup.sh | bash
```

The script rejects unsupported architectures, account/host mismatches, and
invalid checkouts before installing Nix. The checkout must be `~/.dots`;
running a copy elsewhere or setting another `DOTS_DIR` is rejected. Existing
checkouts are reused without pulling or discarding local changes.
It creates `~/Pictures/Screenshots`, runs `darwin-rebuild`, and installs
user-scoped toolchains. Run it without sudo; the Nix installer and system
switch request administrator privileges when needed.

Homebrew installs ComicShannsMono Nerd Font for Ghostty and Paper Mono.
Git commits are signed by default; import the private GPG key matching
`6C3567C3144352E3` before committing.
In repos that use Git LFS, run `git lfs install --local` to add its push hook.
The setup script installs Codex CLI for the `c` alias. The `cc` and `a`
aliases need their CLIs installed separately.

If Home Manager creates `.backup` files, review them before removing them.

### Recover from an interrupted installation

Setup stops at the first failed command. Earlier installations and system
changes remain in place; there is no automatic rollback. Fix the reported
cause, then rerun `bash ~/.dots/scripts/setup.sh`. This retries the workflow,
including the system switch and npm installation, rather than resuming a saved step.

- If a clone was interrupted, inspect `~/.dots`. Preserve any local work before
  moving an incomplete checkout aside and cloning again.
- If Nix was installed but is not found, open a new terminal or run
  `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` before retrying.
- If Nix or Homebrew downloads fail, restore network access and retry. A failed
  Homebrew bundle can leave system settings and some apps already installed.
- If activation reports conflicting `/etc` files or an existing `.backup`,
  inspect and back up the named files before resolving the conflict. Do not
  delete configuration files blindly.
- If the system switch succeeded and only mise/npm failed, retry just the
  remaining commands as your normal user:

  ```sh
  cd ~
  /opt/homebrew/bin/mise install
  NPM_CONFIG_PREFIX="$HOME/.local" /opt/homebrew/bin/mise exec -- npm install -g pnpm @openai/codex portless
  /opt/homebrew/bin/mise reshim
  ```

Open a new terminal and verify `mise doctor`, `npm config get prefix`,
`pnpm --version`, `codex --version`, and `portless --version`. The npm prefix
should be `/Users/k1tyoo/.local`. Restore signing keys and authenticate apps
separately; a successful setup does not restore credentials or application data.

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
Home Manager sets `NPM_CONFIG_PREFIX` to `~/.local`, and setup explicitly uses
the same prefix before the new shell environment is loaded. This takes
precedence over an existing `.npmrc` prefix without replacing that file.
Global npm tools therefore remain available across Node version changes.

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
