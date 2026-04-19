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
hosts/kybook/                    # machine config
modules/darwin/                  # macOS settings and Homebrew packages
modules/home/                    # home-manager modules
config/                          # raw app config snapshots
scripts/                         # setup helpers
```

## stack

- shell: fish, starship
- terminal: ghostty, tmux
- editor: neovim, zed
- node: vite+
- theme: vesper
