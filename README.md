# dotfiles_simple

Personal dotfiles targeting **non-development environments** — servers, routers, temporary machines. The goal is minimal dependencies: the installer works with only `bash` + `curl`, and degrades gracefully as more tools become available.

## Components

| Component | Files |
|-----------|-------|
| `zsh` | `.zshrc` |
| `vim` | `.vimrc`, `.vim/` (with submodules) |
| `nvim` | `.config/nvim/` |
| `tmux` | `.tmux.conf` |
| `kitty-terminfo` | `.terminfo/x/xterm-kitty` |

All top-level directories are components and are auto-discovered — no hardcoded list.

## Install

```bash
git clone --recurse-submodules https://github.com/bincat233/dotfiles_simple ~/.dotfiles_simple
cd ~/.dotfiles_simple
./install.sh --all
```

### Options

```
./install.sh [MODE] [--all | COMPONENTS...]

Modes:
  (none)   Auto-detect: stow if available, else ln -sf
  --stow   GNU Stow (error if not installed)
  --link   ln -sf
  --pull   Network install (no local clone needed)

--all      Install all components
--help     Show help
```

### Pull mode

For remote or low-storage environments (OpenWrt, temporary machines):

```bash
# One-liner, no clone needed
curl -fsSL https://raw.githubusercontent.com/bincat233/dotfiles_simple/main/install.sh \
  | bash -s -- --pull --all
```

Pull mode behavior:
- Fetches file list via GitHub API, downloads each file directly with curl
- **git available**: also clones submodules to their target paths
- **no git**: submodule content is skipped

### Examples

```bash
./install.sh --all              # auto-detect mode, all components
./install.sh zsh tmux           # auto-detect mode, selected components
./install.sh --link --all       # force ln -sf
./install.sh --pull zsh         # pull mode, zsh only
```

## Vim plugins (submodules)

- [catppuccin/vim](https://github.com/catppuccin/vim) — colorscheme
- [github/copilot.vim](https://github.com/github/copilot.vim) — Copilot
- [tpope/vim-sensible](https://github.com/tpope/vim-sensible) — sensible defaults

## Neovim plugins (mini.deps)

The core Neovim configuration works without plugins. On first launch, the configuration uses Git to bootstrap [mini.nvim](https://github.com/nvim-mini/mini.nvim), then installs optional plugins with its `mini.deps` module:

- [catppuccin/nvim](https://github.com/catppuccin/nvim) — colorscheme
- [nvim-mini/mini.nvim](https://github.com/nvim-mini/mini.nvim) — lightweight editing enhancements

Neovim 0.9 uses mini.nvim v0.17.0 and Catppuccin v1.11.0; Neovim 0.10 and newer use current stable releases. Existing installations are never updated during startup. Use `:DepsUpdate` to update plugins, `:DepsClean` to remove unused plugins, and `:DepsSnapSave` / `:DepsSnapLoad` to manage snapshots. After changing between Neovim 0.9 and a newer release, run `:DepsUpdateOffline` once to apply the matching plugin versions.

Neovim 0.9 overrides live in `lua/plugin_compat/nvim_0_9.lua`. Add a plugin entry there whenever its current release no longer supports Neovim 0.9; plugin selection remains in `init.lua`.

If Git or the network is unavailable, Neovim starts with the core configuration and the built-in `habamax` colorscheme.

### Test Neovim without installing it

From the repository root, point Neovim at the tracked configuration and isolated state directories. This bypasses both `~/.config/nvim` and its plugins:

```bash
# Create a disposable Neovim environment.
test_root="$(mktemp -d)"

# Load this repository's config without touching local config, plugins, or state.
XDG_CONFIG_HOME="$PWD/nvim/.config" \
XDG_DATA_HOME="$test_root/data" \
XDG_STATE_HOME="$test_root/state" \
XDG_CACHE_HOME="$test_root/cache" \
nvim
```

The first run needs Git and network access to install plugins. The temporary directory can be removed after testing.
