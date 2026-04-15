# dotfiles_simple

Personal dotfiles targeting **non-development environments** — servers, routers, temporary machines. The goal is minimal dependencies: the installer works with only `bash` + `curl`, and degrades gracefully as more tools become available.

## Components

| Component | Files |
|-----------|-------|
| `zsh` | `.zshrc` |
| `vim` | `.vimrc`, `.vim/` (with submodules) |
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
- **git available**: shallow-clones to `~/.dotfiles_simple`, then symlinks
- **no git**: fetches file list via GitHub API, downloads each file with curl (submodule content excluded)

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
