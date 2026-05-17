# dots

nix-darwin + home-manager config for macOS Apple Silicon.

## install

```sh
curl -fsSL https://raw.githubusercontent.com/k1tyoodev/dots/main/scripts/setup.sh | bash
```

Run the setup script as your normal user. It will prompt for `sudo` only when needed.

## rebuild

```sh
rebuild
```

## structure

```text
.
|-- .github/                         # GitHub repository automation
|   `-- workflows/
|       `-- flake-update.yml         # workflow for updating Nix flake inputs
|-- config/                          # raw app config files symlinked by home-manager
|   |-- bat/
|   |   `-- themes/
|   |       `-- vesper.tmTheme       # Vesper syntax theme for bat
|   |-- btop/
|   |   `-- themes/
|   |       `-- vesper.theme         # Vesper color theme for btop
|   |-- ghostty/
|   |   `-- config                   # Ghostty terminal settings
|   |-- nvim/
|   |   |-- README.md                # Neovim keybinding and plugin notes
|   |   |-- init.lua                 # full Neovim Lua configuration
|   |   `-- lazy-lock.json           # lazy.nvim plugin lockfile
|   |-- vite-plus/
|   |   `-- config.json              # Vite+ default Node version
|   `-- zed/
|       |-- keymap.json              # Zed custom keybindings
|       `-- settings.json            # Zed editor, terminal, Git, and UI settings
|-- hosts/
|   `-- kybook/
|       |-- default.nix              # machine-level nix-darwin config
|       `-- home.nix                 # home-manager entrypoint for k1tyoo
|-- modules/
|   |-- darwin/
|   |   |-- homebrew.nix             # Homebrew taps, brews, and casks
|   |   `-- system.nix               # macOS defaults and Touch ID sudo
|   `-- home/
|       |-- dev.nix                  # fd, ripgrep, Yazi, btop, bat, and gh config
|       |-- editors/
|       |   |-- neovim.nix           # enables Neovim and links config/nvim
|       |   `-- zed.nix              # links Zed settings and keymap
|       |-- git.nix                  # Git identity, signing, aliases, and defaults
|       |-- packages/
|       |   `-- node.nix             # Vite+ Node environment and config link
|       |-- shell/
|       |   |-- fish.nix             # Fish shell, aliases, PATH, and integrations
|       |   `-- starship.nix         # Starship prompt styling
|       `-- terminal/
|           |-- ghostty.nix          # links Ghostty config
|           `-- tmux.nix             # tmux settings, plugins, and sessionizer
|-- scripts/
|   `-- setup.sh                     # first-run macOS bootstrap script
|-- .gitignore                       # repository-local ignore rules
|-- README.md                        # project overview and usage notes
|-- flake.lock                       # locked Nix input revisions
`-- flake.nix                        # main Nix flake entrypoint
```

## stack

- shell: fish, starship
- terminal: ghostty, tmux
- editor: neovim, zed
- node: vite+
- theme: vesper
